from langchain.tools import tool
from langchain.pydantic_v1 import BaseModel, Field
from langchain_community.document_loaders import AsyncHtmlLoader
from langchain_community.document_transformers import Html2TextTransformer

class URLLoaderInput(BaseModel):
    url: str = Field(description="""网页url""")

@tool("url-loader", args_schema=URLLoaderInput)
def url_loader(url: str) -> str:
    """加载url内容"""
    urls = [url]
    loader = AsyncHtmlLoader(urls)
    docs = loader.load()

    html2text = Html2TextTransformer()
    docs_transformed = html2text.transform_documents(docs)

    return "\n\n".join([doc.page_content for doc in docs_transformed])

if __name__ == "__main__":
    import sys
    print(url_loader(sys.argv[1]))
