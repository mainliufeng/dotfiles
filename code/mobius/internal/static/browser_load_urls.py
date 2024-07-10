import sys
import asyncio
from playwright.async_api import async_playwright, TimeoutError as PlaywrightTimeoutError
import html2text

async def fetch_content(browser, url):
    page = await browser.new_page()
    try:
        await page.goto(url, timeout=10000)  # 设置10s超时时间
        content = await page.content()
        text_content = html2text.html2text(content)
    except PlaywrightTimeoutError:
        print(f"Timeout while loading: {url}")
        text_content = None
    except Exception as e:
        print(f"Error while loading {url}: {e}")
        text_content = None
    finally:
        await page.close()
    return text_content

async def load_urls(urls):
    text_contents = []
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)  # 设置 headless=True 以在后台运行浏览器
        tasks = [fetch_content(browser, url) for url in urls]
        text_contents = await asyncio.gather(*tasks)
        await browser.close()
    return [content for content in text_contents if content is not None]

# 示例用法
urls = sys.argv[1:]
text_contents = asyncio.run(load_urls(urls))
for text_content in text_contents:
    print(f"{text_content[:2000]}\n")  # 只输出前2000个字符以示例

