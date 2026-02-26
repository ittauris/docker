FROM python:3.11-alpine

RUN apk add --no-cache curl

RUN pip install prometheus-client pyzabbix requests

WORKDIR /app
COPY exporter.py debug-avaiable.py .

EXPOSE 9285

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:9285/metrics || exit 1

CMD ["python", "exporter.py"]
