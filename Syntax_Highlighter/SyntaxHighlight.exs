# Mateo Herrera - A01751912
# Gerardo Gutierrez - A01029422
# Use of regex and language interpratation knowledge
# to create a json file token identifier.
# The identified tokens are returned in a html file.
# Example calls:
# Highlighter.syntaxHighlight("Test_files/example_0.json")

defmodule Highlighter do
    
    # Function that reads a file and applies the token identifier function
    # to each line.
    def syntaxHighlight(in_filename) do
        code =
            in_filename
            |> File.stream!()
            |> Enum.map(&code_from_line/1)
            |> Enum.join()
        createHtml(code)
    end
    
    # Function that accepts a line from a file. This function then identifies
    # all json tokens inside the line and places them inside a span with
    # an appropiriate class identifier.
    # This function returns the line with its replacements.
    def code_from_line(line) do
        cond do
            Regex.run(~r|("\S+")\s*:|, line) != nil ->
                line = Regex.replace(~r|("\S+")\s*:|, line,
                "<span class='object-key'>\\1</span><span class='punctuation'>:</span>")
                code_from_line(line)
            Regex.run(~r{"[^"<]*"(?!<\/)}, line) != nil ->
                line = Regex.replace(~r{"[^"<]*"(?!<\/)}, line, 
                "<span class='string'>\\0</span>")
                code_from_line(line)
            Regex.run(~r{[\dEe.+-]*\d(?![.])\b(?!<\/)(?!.*")}, line) != nil ->
                line = Regex.replace(~r{[\dEe.+-]*\d(?![.])\b(?!<\/)(?!.*")},
                line, "<span class='number'>\\0</span>")
                code_from_line(line)
            Regex.run(~r{null(?!<\/)|true(?!<\/)|false(?!<\/)}, line) != nil ->
                line = Regex.replace(~r{null(?!<\/)|true(?!<\/)|false(?!<\/)}, 
                line, "<span class='reserved-word'>\\0</span>")
                code_from_line(line)
            Regex.run(~r/{(?!<\/)|}(?!<\/)|,(?!<\/)(?=[^¨] *<|\n)|[[](?!<\/)|[]](?!<\/)/, 
            line) != nil ->
                line = Regex.replace(~r/{(?!<\/)|}(?!<\/)|,(?!<\/)(?=[^¨] *<|\n)|[[](?!<\/)|[]](?!<\/)/,
                line, "<span class='punctuation'>\\0</span>")
                code_from_line(line)
            true ->
                line
        end
    end

    # This function creates a new html file based on a template and it inserts
    # the token identified json code.
    def createHtml(code) do
        html =
            "template_page.html"
            |> File.stream!()
            |> Enum.map(&(Regex.replace(~r|^~a$|, &1, code)))
            |> Enum.map(&(Regex.replace(~r|~a|, &1, "#{Date.utc_today()}")))
            |> Enum.join()
        File.write("index.html", html)
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