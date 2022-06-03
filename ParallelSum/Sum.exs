defmodule Hw.Primes do
    def checkPrime(n) when n < 2, do: false
    def checkPrime(n) when n == 2, do: true
    def checkPrime(n), do: checkPrimeAux(n, 2, abs(:math.sqrt(n)))
        defp checkPrimeAux(n, i, _limit) when rem(n, i) == 0, do: false
        defp checkPrimeAux(_n, i, limit) when i >= limit, do: true
        defp checkPrimeAux(n, i, limit), do: checkPrimeAux(n, i + 1, limit)

    def sum_primes(limit), do: sum_primesAux({0, limit}, 0)

    defp sum_primesAux({start, limit}, res) when start > limit, do: res
    defp sum_primesAux({start, limit}, res) do
        if checkPrime(start) do
            sum_primesAux({start + 1, limit}, res + start)
        else
            sum_primesAux({start + 1, limit}, res)
        end
    end

    def sum_primes_parallel(limit, threads \\ System.schedulers) do
        coeficient = div(limit, threads)
        remainder = rem(limit, threads)
        limits = Enum.to_list(coeficient+remainder..limit//coeficient)
        starts = [0 | Enum.to_list(coeficient+remainder+1..limit//coeficient)]
        Enum.zip(starts, limits)
            |>Enum.map(&Task.async(fn -> sum_primesAux(&1, 0) end))
            |>Enum.map(&Task.await(&1))
            |>Enum.sum()
    end
end