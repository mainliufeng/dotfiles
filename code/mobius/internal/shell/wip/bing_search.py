#!/usr/bin/env python

import sys
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import time
from bs4 import BeautifulSoup
import json

def get_search_results(keyword):
    # Setup Chrome driver
    options = webdriver.ChromeOptions()
    options.add_argument('--headless')  # Run in headless mode
    options.add_argument('--disable-gpu')
    driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=options)

    # Open Bing and search for the keyword
    driver.get("https://www.bing.com")

    try:
        # Wait until the search box is present
        search_box = WebDriverWait(driver, 10).until(
            EC.presence_of_element_located((By.NAME, "q"))
        )
        search_box.send_keys(keyword)
        search_box.send_keys(Keys.RETURN)
    except Exception as e:
        print(f"An error occurred: {e}")
        driver.quit()
        return []

    try:
        # Wait for search results to load
        WebDriverWait(driver, 10).until(
            EC.presence_of_element_located((By.CSS_SELECTOR, "li.b_algo h2 a"))
        )
    except Exception as e:
        print(f"An error occurred: {e}")
        driver.quit()
        return []

    # Get the first 5 search result links
    search_results = driver.find_elements(By.CSS_SELECTOR, "li.b_algo h2 a")[:5]
    results = []

    for result in search_results:
        title = result.text
        url = result.get_attribute('href')
        
        # Open the link and get the content
        driver.get(url)
        try:
            WebDriverWait(driver, 10).until(
                EC.presence_of_element_located((By.TAG_NAME, "p"))
            )
        except Exception as e:
            print(f"An error occurred while loading the page: {e}")
            continue
        
        soup = BeautifulSoup(driver.page_source, 'html.parser')
        content = ' '.join(p.text for p in soup.find_all('p'))
        
        results.append({
            "title": title,
            "url": url,
            "content": content
        })

        # Return to search results page
        driver.back()
        try:
            WebDriverWait(driver, 10).until(
                EC.presence_of_element_located((By.CSS_SELECTOR, "li.b_algo h2 a"))
            )
        except Exception as e:
            print(f"An error occurred while returning to the search results: {e}")
            break

    driver.quit()
    return results

def main():
    if len(sys.argv) < 2:
        print("Usage: python script.py <search_keyword>")
        sys.exit(1)

    keyword = sys.argv[1]
    results = get_search_results(keyword)
    
    # Print results as JSON
    for result in results:
        print(json.dumps(result, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()

