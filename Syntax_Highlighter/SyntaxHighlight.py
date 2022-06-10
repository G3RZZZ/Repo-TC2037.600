import re
from datetime import date

def syntaxHighlight(filename):
    file = open(filename)
    lines = file.readlines()
    code = ""
    file.close()
    for i in range(0,len(lines)):
        print(identify(lines[i]))
        lines[i] = identify(lines[i])
    code = code.join(lines)
    writeHtml(code, filename)

def identify(lines):
    identifiedLines = ""
    while lines != "":
        if re.search("^\s+", lines):
            match = re.search("^\s+", lines)
            identifiedLines += match.group()
            lines = lines.replace(match.group(),'')
        elif re.search('^"[^"]+" *:', lines):
            match = re.search('^"[^"]+" *:', lines)
            identifiedLines += htmlTag(match.group().replace(":", ""), "object-key")
            identifiedLines += htmlTag(":", "punctuation")
            lines = lines.replace(match.group(),'',1)
        elif re.search('^".*?"(?=\s|,|]|})', lines):
            match = re.search('^".*?"(?=\s|,|]|})', lines)
            identifiedLines += htmlTag(match.group(), "string")
            lines = lines.replace(match.group(),'',1)
        elif re.search('^-?\d+[.]?\d*[Ee]?[+-]?\d*(?=\s|,|]|})', lines):
            match = re.search('^-?\d+[.]?\d*[Ee]?[+-]?\d*(?=\s|,|]|})', lines)
            identifiedLines += htmlTag(match.group(), "number")
            lines = lines.replace(match.group(),'',1)
        elif re.search('^null|^true|^false', lines):
            match = re.search('^null|^true|^false', lines)
            identifiedLines += htmlTag(match.group(), "reserved-word")
            lines = lines.replace(match.group(),'',1)
        elif re.search('^[[]|^[]]|^{|^}|^,', lines):
            match = re.search('^[[]|^[]]|^{|^}|^,', lines)
            identifiedLines += htmlTag(match.group(), "punctuation")
            lines = lines.replace(match.group(),' ',1)
        else:
            break
    return identifiedLines
        

def htmlTag(token, id):
    return "<span class='" + id + "'>" + token + "</span>"

def writeHtml(lines, filename):
    # templatefile = open("template_page.html")
    # file = open((filename.replace("json", "html")), "w")
    # file.write = templatefile.read()
    # templatefile.close()
    # file.write()
    # file.close()

    with open("template_page.html", "rt") as fin:
        with open(filename.replace("json", "html"), "wt") as fout:
            for line in fin:
                fout.write(line.replace("~a", date.today()))
                fout.write(line.replace("~b", lines))
        fout.close()
        fin.close()

