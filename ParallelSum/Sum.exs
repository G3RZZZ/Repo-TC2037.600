# Mateo Herrera - A01751912
# Gerardo Gutierrez - A01029422

# Use of concurrency and parallel execution to calculate te sum of all prime
# numbers before a limit. This modue also has the option to calculate this
# sequentially so as to compare the execution times.

# Example calls:
# Hw.Primes.sum_primes(1000)
# Hw.Primes.sum_primes_parallel(1000, 3)


defmodule Hw.Primes do

    # This function checks wether or not a number n is a prime number using
    # recursion.
    def checkPrime(n) when n < 2, do: false
    def checkPrime(n) when n == 2, do: true
    def checkPrime(n), do: checkPrimeAux(n, 2, abs(:math.sqrt(n)))
        defp checkPrimeAux(n, i, _limit) when rem(n, i) == 0, do: false
        defp checkPrimeAux(_n, i, limit) when i >= limit, do: true
        defp checkPrimeAux(n, i, limit), do: checkPrimeAux(n, i + 1, limit)

    # This function calls the recursive sum funtion sequentially.
    def sum_primes(limit), do: sum_primesAux({0, limit}, 0)

    # This function adds up the prime numbers from start to limit(i.e 0 -> 1000).
    # It does this via recursion and pattern matching.
    defp sum_primesAux({start, limit}, res) when start > limit, do: res
    defp sum_primesAux({start, limit}, res) do
        if checkPrime(start) do
            sum_primesAux({start + 1, limit}, res + start)
        else
            sum_primesAux({start + 1, limit}, res)
        end
    end

    # This function calls the recursive sum function and executes it in
    # parallel according to the number of threads specified or the max number
    # of cores in the system.
    def sum_primes_parallel(limit, threads \\ System.schedulers) do
        coeficient = div(limit, threads)
        remainder = rem(limit, threads)
        limits = Enum.to_list(coeficient+remainder..limit//coeficient)
        starts = [0 | Enum.to_list(coeficient+remainder+1..limit//coeficient)]
        Enum.zip(starts, limits)
            |>Enum.map(&Task.async(fn -> sum_primesAux(&1, 0) end))
            |>Enum.map(&Task.await(&1, :infinity))
            |>Enum.sum()
    end
end

# Module that checks a function execution time.
# Taken from:
# https://stackoverflow.com/questions/29668635/how-can-we-easily-time-function-calls-in-elixir
# Example call:
# Benchmark.measure(fn -> Hw.Primes.sum_primes_parallel(1000, 3) end)
defmodule Benchmark do
  def measure(function) do
    function
    |> :timer.tc
    |> elem(0)
    |> Kernel./(1_000_000)
  end
end
