database
alembic revision -m "create initial tables" --autogenerate
alembic upgrade head

app run locally
uvicorn main:app --reload     


python.analysis.typeCheckingMode