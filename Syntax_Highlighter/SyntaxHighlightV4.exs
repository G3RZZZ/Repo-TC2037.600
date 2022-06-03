# Mateo Herrera - A01751912
# Gerardo Gutierrez - A01029422

# Use of regex and language interpratation knowledge
# to create a json file token identifier.
# The identified tokens are returned in a html file.
# This version supports multi file parallel identification and it also 
# does the same thing sequentially for comparison.

# Example calls:
# Highlighter.syntaxHighlight("Test_files/example_0.json")

defmodule Highlighter do

    # Function that reads a file and applies V2 identify function on each line
    # of the file for better performance.
    def syntaxHighlight(in_filename) do
        code =
            in_filename
            |> File.stream!()
            |> Enum.map(&identify&1)
            |> Enum.join("\n")   
        createHtml(code, String.replace(in_filename, "Test_files", "Result_files"))
    end

    # Function that accepts a line from the json file and identifies its tokens
    # It does this by placing already identified tokens in a list
    # and removing them from the original string. When every token is identified
    # and the string is empty, the function returns the list that was 
    # turned into a string beforehand.
    def identify(code), do: identify_tail(code, [])
        # defp identify_tail("", lst), do: to_string(lst)
        defp identify_tail(code, newLine) do
            cond do
                #Space/tab/enter regex identifier
                String.match?(code, ~r{^\s+}) ->
                    match = Regex.run(~r{(^\s+)(.*)}, code)
                    identify_tail(Enum.at(match, 2), [Enum.at(match, 1) | newLine])
                #Object key regex identifier
                String.match?(code, ~r{^"[^"]+" *:}) ->
                    match = Regex.run(~r{((^"[^"]+" *)(:))(.*)}, code)
                    identify_tail(Enum.at(match, 4), [htmlTag(Enum.at(match, 3),
                    "punctuation"), htmlTag(Enum.at(match, 2),
                     "object-key") | newLine])
                #String regex identifier
                String.match?(code, ~r/^".*?"(?=\s|,|]|})/) ->
                    match = Regex.run(~r/(^".*?"(?=\s|,|]|}))(.*)/, code)
                    identify_tail(Enum.at(match, 2), [htmlTag(Enum.at(match, 1),
                    "string") | newLine])
                #Number regex identifier
                String.match?(code, ~r/^-?\d+[.]?\d*[Ee]?[+-]?\d*(?=\s|,|]|})/) ->
                    match = Regex.run(~r/(^-?\d+[.]?\d*[Ee]?[+-]?\d*(?=\s|,|]|}))(.*)/, code)
                    identify_tail(Enum.at(match, 2), [htmlTag(Enum.at(match, 1),
                    "number") | newLine])
                #Reserved word regex identifier
                String.match?(code, ~r{^null|^true|^false}) ->
                    match = Regex.run(~r{(^null|^true|^false)(.*)}, code)
                    identify_tail(Enum.at(match, 2), [htmlTag(Enum.at(match, 1),
                    "number") | newLine])
                #Punctuation regex identifier
                String.match?(code, ~r/^[[]|^[]]|^{|^}|^,/) ->
                    match = Regex.run(~r/(^[[]|^[]]|^{|^}|^,)(.*)/, code)
                    identify_tail(Enum.at(match, 2), [htmlTag(Enum.at(match, 1),
                    "punctuation") | newLine])
                true ->
                    to_string(Enum.reverse(newLine))
            end
        end

    # This function is used to create the HTML tags that contain the idenified
    # json tokens.
    def htmlTag(token, id), do: "<span class='#{id}'>#{to_string(token)}</span>"    

    # This function creates a new html file based on a template and it inserts
    # the token identified json code.
    def createHtml(code, filename) do
        html =
            "template_page.html"
            |> File.stream!()
            |> Enum.map(&(String.replace(&1, "~a", "#{Date.utc_today()}")))
            |> Enum.map(&(String.replace(&1, "~b", code)))
            |> Enum.join()
        File.write(String.replace(filename, ".json", ".html"), html)
    end

    # This function retrieves all json files inside a folder in this directory,
    # It then uses concurrency to identify the files in the folder in parallel.
    def multiSyntaxHighlightParallel(folder) do
        Path.wildcard("./#{folder}/*.json")
        |> Enum.map(&Task.async(fn -> syntaxHighlight(&1) end))
        |> Enum.map(&Task.await(&1))
    end

    # This function retrieves all json files inside a folder in this directory,
    # It then executes the highlight function sequentially.
    def multiSyntaxHighlightSequential(folder) do
        Path.wildcard("./#{folder}/*.json")
        |> Enum.map(&syntaxHighlight(&1))
    end

end

# Module that checks a function execution time.
# Taken from:
# https://stackoverflow.com/questions/29668635/how-can-we-easily-time-function-calls-in-elixir
# Example call:
# Benchmark.measure(fn -> Highlighter.syntaxHighlight("Test_files/example_0.json") end)
defmodule Benchmark do
  def measure(function) do
    function
    |> :timer.tc
    |> elem(0)
    |> Kernel./(1_000_000)
  end
end
