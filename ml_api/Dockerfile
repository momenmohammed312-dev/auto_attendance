# استخدام نسخة بايثون رسمية وخفيفة
FROM python:3.10-slim

# تثبيت مكتبات النظام الضرورية لتشغيل OpenCV و DeepFace
RUN apt-get update && apt-get install -y \
    libgl1-mesa-glx \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# تحديد مسار العمل داخل الحاوية
WORKDIR /code

# نسخ ملف المكتبات أولاً
COPY ./requirements.txt /code/requirements.txt

# تثبيت مكتبات بايثون
RUN pip install --no-cache-dir --upgrade -r /code/requirements.txt

# نسخ باقي ملفات المشروع (بما فيها encodings.json وموديلات الـ face_recognition لو موجودة)
COPY . .

# إعداد مستخدم بصلاحيات محدودة ليناسب بيئة Hugging Face Spaces
RUN useradd -m -u 1000 user
USER user
ENV HOME=/home/user \
    PATH=/home/user/.local/bin:$PATH

# تشغيل الـ API (الملف اسمه main والـ FastAPI instance اسمها app)
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "7860"]
