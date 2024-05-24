#!/usr/bin/env python

import sys
import json
import concurrent.futures
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.service import Service as ChromeService
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from webdriver_manager.chrome import ChromeDriverManager
from langchain_community.document_loaders import AsyncHtmlLoader
from langchain_community.document_transformers import Html2TextTransformer

def fetch_content(url):
    """Fetch content from a single URL."""
    loader = AsyncHtmlLoader([url])
    docs = loader.load()
    html2text = Html2TextTransformer()
    docs_transformed = html2text.transform_documents(docs)
    return docs_transformed[0].page_content if docs_transformed else ""

def google_search(query):
    options = webdriver.ChromeOptions()
    options.add_argument("--headless")
    driver = webdriver.Chrome(service=ChromeService(ChromeDriverManager().install()), options=options)

    try:
        driver.get("https://www.google.com")
        WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.NAME, "q")))

        search_box = driver.find_element(By.NAME, "q")
        search_box.send_keys(query)
        search_box.send_keys(Keys.RETURN)
        
        WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.CSS_SELECTOR, 'div.g')))
        results = driver.find_elements(By.CSS_SELECTOR, 'div.g')[:5]

        urls = []
        titles = []
        for result in results:
            try:
                title_element = result.find_element(By.TAG_NAME, 'h3')
                link_element = result.find_element(By.TAG_NAME, 'a')
                title = title_element.text
                link = link_element.get_attribute('href')
                urls.append(link)
                titles.append(title)
            except Exception as e:
                continue

        with concurrent.futures.ThreadPoolExecutor() as executor:
            contents = list(executor.map(fetch_content, urls))

        for title, link, content in zip(titles, urls, contents):
            result_json = {
                "title": title,
                "url": link,
                "content": content
            }
            print(json.dumps(result_json, ensure_ascii=False))

    except Exception as e:
        print(f"An error occurred: {e}")

    finally:
        driver.quit()

if __name__ == "__main__":
    query = sys.argv[1]
    google_search(query)

