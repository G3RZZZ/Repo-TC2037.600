# Use of regex and language interpratation knowledge
# to create a json file token identifier.
# Example calls:
# Highlighter.syntaxHighlight("Test_files/example_0.json")
# Mateo Herrera - A01751912
# Gerardo Gutierrez - A01029422

defmodule Highlighter do
    
    def syntaxHighlight(in_filename) do
        code =
            in_filename
            |> File.stream!()
            |> Enum.map(&code_from_line/1)
            |> Enum.join()
        createHtml(code)
    end
    
    def code_from_line(line) do
        cond do
            Regex.run(~r|("\S+")\s*:|, line) != nil ->
                line = Regex.replace(~r|("\S+")\s*:|, line,"<span class='object-key'>\\1</span><span class='punctuation'>:</span>")
                code_from_line(line)
            Regex.run(~r{"[^"<]+"(?!<)}, line) != nil ->
                line = Regex.replace(~r{"[^"<]+"(?!<)}, line, "<span class='string'>\\0</span>")
                code_from_line(line)
            Regex.run(~r{[\dE.+-]+\d(?![.])\b(?!<)}, line) != nil ->
                line = Regex.replace(~r{[\dE.+-]+\d(?![.])\b(?!<)}, line, "<span class='number'>\\0</span>")
                code_from_line(line)
            Regex.run(~r{null(?!<)|true(?!<)|false(?!<)}, line) != nil ->
                line = Regex.replace(~r{null(?!<)|true(?!<)|false(?!<)}, line, "<span class='reserved-word'>\\0</span>")
                code_from_line(line)
            Regex.run(~r/{(?!<)|}(?!<)|,(?!<)|[[](?!<)|[]](?!<)/, line) != nil ->
                line = Regex.replace(~r/{(?!<)|}(?!<)|,(?!<)|[[](?!<)|[]](?!<)/, line,"<span class='punctuation'>\\0</span>")
                code_from_line(line)
            true ->
                line
        end
    end

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

