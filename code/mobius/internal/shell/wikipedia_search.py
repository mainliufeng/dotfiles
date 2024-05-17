#!/usr/bin/env python

import sys
import wikipedia

top_k_results = 1
doc_content_chars_max = 4000

if "--lang" in sys.argv:
    language_index = sys.argv.index("--lang") + 1
    if language_index < len(sys.argv):
        language = sys.argv[language_index]
        wikipedia.set_lang(language)

if len(sys.argv) > 1:
    query = sys.argv[1]
    page_titles = wikipedia.search(query)
    summaries = []
    for page_title in page_titles[:top_k_results]:
        if wiki_page := wikipedia.page(title=page_title, auto_suggest=False):
            print(wiki_page)
            summary = f"Page: {page_title}\nSummary: {wiki_page.summary}\nContent: {wiki_page.content}"
            if summary:
                summaries.append(summary)
    if summaries:
        print("\n\n".join(summaries)[:doc_content_chars_max])

