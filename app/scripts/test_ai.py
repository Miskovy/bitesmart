# import google.genai as genai
# from app.config.config import settings
#
# client = genai.Client(api_key=settings.GEMINI_API_KEY)
#
# print("Your API Key has access to these text models:")
# for m in genai.list_models():
#     if 'generateContent' in m.supported_generation_methods:
#         print(m.name)