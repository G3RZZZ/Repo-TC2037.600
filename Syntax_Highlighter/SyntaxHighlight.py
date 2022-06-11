# Mateo Herrera - A01751912
# Gerardo Gutierrez - A01029422

# Use of regex and language interpratation knowledge
# to create a json file token identifier.
# The identified tokens are returned in a html file.
# This version supports multi file parallel identification and it also
# does the same thing sequentially for comparison.
# Python Version

# Example calls:
# python .\SyntaxHighlight.py "Test_big_files"

import re
from datetime import date
import time
import multiprocessing
import os
import sys

def syntaxHighlight(filename):
    file = open(filename)
    lines = file.readlines()
    code = ""
    file.close()
    for i in range(0,len(lines)):
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
        elif re.search('^[\[]|^[\]]|^{|^}|^,', lines):
            match = re.search('^[\[]|^[\]]|^{|^}|^,', lines)
            identifiedLines += htmlTag(match.group(), "punctuation")
            lines = lines.replace(match.group(),' ',1)
        else:
            break
    return identifiedLines
        

def htmlTag(token, id):
    return "<span class='" + id + "'>" + token + "</span>"

def writeHtml(lines, filename):
    filename = filename.replace("Test", "Result")
    with open("template_page.html", "rt") as fin:
        with open(filename.replace("json", "html"), "wt") as fout:
            for line in fin:
                # fout.write(line.replace("~a", date.today().strftime("%d/%m/%Y")))
                fout.write(line.replace("~b", lines))
        fout.close()
        fin.close()

def multiSyntaxHighlightParallel(folder):
    files = os.listdir(folder)
    for i in range(len(files)):
        files[i] = folder + "/" + files[i]
    if __name__ == '__main__':
        pool = multiprocessing.Pool(multiprocessing.cpu_count())
        outputs_async = pool.map_async(syntaxHighlight, files)
        outputs = outputs_async.get()
        print("Output: {}".format(outputs))

def multiSyntaxHighlightSequential(folder):
    files = os.listdir(folder)
    for i in range(len(files)):
        files[i] = folder + "/" + files[i]
        syntaxHighlight(files[i])

start = time.time()
multiSyntaxHighlightParallel(sys.argv[1])
end = time.time()
print ("Execution time: %s"  % (end-start))
