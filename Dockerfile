FROM ubuntu:22.04

WORKDIR /app

ENV DEBIAN_FRONTEND=noninteractive
ENV DATABASE_URL=postgresql://username:password@contacts-db/contacts_db
RUN apt-get update && apt-get install -y \
 python3 \
python3-pip \
&& rm -rf /var/lib/apt/lists/*

RUN pip3 install --upgrade pip

COPY . /app
#COPY requirements.txt /app/
RUN pip3 install --no-cache-dir -r requirements.txt

CMD ["python3", "app.py"]

EXPOSE 5000