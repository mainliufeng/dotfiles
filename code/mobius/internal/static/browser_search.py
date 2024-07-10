import sys

import asyncio
from playwright.async_api import async_playwright

async def search_google(query):
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=False)  # 设置 headless=True 以在后台运行浏览器
        page = await browser.new_page()
        await page.goto("https://www.google.com")

        # 等待搜索框出现
        await page.wait_for_selector("textarea[name=q]", timeout=60000)

        # 输入搜索关键词并进行搜索
        await page.fill("textarea[name=q]", query)
        await page.press("textarea[name=q]", "Enter")

        # 等待搜索结果加载
        await page.wait_for_selector("div#search", timeout=60000)

        results = []

        # 获取搜索结果
        search_results = await page.query_selector_all("div.g")

        for result in search_results:
            title_element = await result.query_selector("h3")
            title = await title_element.evaluate("node => node.innerText") if title_element else "No title"
            
            url_element = await result.query_selector("a")
            url = await url_element.evaluate("node => node.href") if url_element else "No URL"
            results.append({"title": title, "url": url})

        await browser.close()
        return results

# 示例用法
query = sys.argv[1]
results = asyncio.run(search_google(query))
for result in results:
    print(f"Title: {result['title']}\nURL: {result['url']}\n")

