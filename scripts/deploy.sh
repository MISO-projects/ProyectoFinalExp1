#!/bin/bash

GOOGLE_CLOUD_PROJECT=$(gcloud config get project)
ORDER_COMMAND_API_IMAGE="us-central1-docker.pkg.dev/$GOOGLE_CLOUD_PROJECT/medisupply/order-command-api"
ORDER_COMMAND_HANDLER_IMAGE="us-central1-docker.pkg.dev/$GOOGLE_CLOUD_PROJECT/medisupply/order-command-handler"
ORDER_QUERY_API_IMAGE="us-central1-docker.pkg.dev/$GOOGLE_CLOUD_PROJECT/medisupply/order-query-api"
ORDER_PROJECTION_HANDLER_IMAGE="us-central1-docker.pkg.dev/$GOOGLE_CLOUD_PROJECT/medisupply/order-query-projection"
CLOUDSQL_INSTANCE_CONNECTION_NAME="$GOOGLE_CLOUD_PROJECT:us-central1:miso-tutorial-calculadora-db"
SERVICE_ACCOUNT_NAME="orders-service"
SERVICE_ACCOUNT_EMAIL="$SERVICE_ACCOUNT_NAME@$GOOGLE_CLOUD_PROJECT.iam.gserviceaccount.com"

# Get the script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

if [ "$1" == "order-command-api" ]; then
    echo "Deploying order-command-api"
    gcloud builds submit --region us-central1 --config "$PROJECT_ROOT/src/commands/api/cloudbuild.yaml" "$PROJECT_ROOT/src/commands/api"
    # Deploy to Cloud Run
    gcloud run deploy order-command-api \
        --image $ORDER_COMMAND_API_IMAGE \
        --allow-unauthenticated \
        --region us-central1 \
        --memory=1Gi \
        --cpu=1 \
        --max-instances=3 \
        --timeout=600s \
        --service-account=$SERVICE_ACCOUNT_EMAIL \
        --set-env-vars=GOOGLE_CLOUD_PROJECT_ID=$GOOGLE_CLOUD_PROJECT,PUBSUB_TOPIC_NAME=create-order-command
elif [ "$1" == "order-command-handler" ]; then
    echo "Deploying order-command-handler"
    gcloud builds submit --region us-central1 --tag $ORDER_COMMAND_HANDLER_IMAGE "$PROJECT_ROOT/src/commands/handlers"
    # Deploy to Cloud Run
    gcloud run deploy order-command-handler \
        --image $ORDER_COMMAND_HANDLER_IMAGE \
        --allow-unauthenticated \
        --region us-central1 \
        --memory=1Gi \
        --cpu=1 \
        --max-instances=3 \
        --timeout=600s \
        --service-account=$SERVICE_ACCOUNT_EMAIL \
        --set-cloudsql-instances=$CLOUDSQL_INSTANCE_CONNECTION_NAME \
        --network=projects/$GOOGLE_CLOUD_PROJECT/global/networks/vpn-tutoriales-miso \
        --subnet=projects/$GOOGLE_CLOUD_PROJECT/regions/us-central1/subnetworks/red-k8s-tutoriales \
        --set-secrets=POSTGRES_PASSWORD=medisupply_orders-postgres_password:latest \
        --set-env-vars=GOOGLE_CLOUD_PROJECT_ID=$GOOGLE_CLOUD_PROJECT,PUBSUB_TOPIC_NAME=order-created,POSTGRES_USER=postgres,POSTGRES_HOST=192.168.0.3,POSTGRES_PORT=5432,POSTGRES_DB=postgres

elif [ "$1" == "order-query-api" ]; then
    echo "Deploying order-query-api"
    gcloud builds submit --region us-central1 --tag $ORDER_QUERY_API_IMAGE "$PROJECT_ROOT/src/queries/api"
    # Deploy to Cloud Run
    gcloud run deploy order-query-api \
        --image $ORDER_QUERY_API_IMAGE \
        --allow-unauthenticated \
        --region us-central1 \
        --memory=1Gi \
        --cpu=1 \
        --max-instances=3 \
        --timeout=600s \
        --service-account=$SERVICE_ACCOUNT_EMAIL \
        --set-cloudsql-instances=$CLOUDSQL_INSTANCE_CONNECTION_NAME \
        --network=projects/$GOOGLE_CLOUD_PROJECT/global/networks/vpn-tutoriales-miso \
        --subnet=projects/$GOOGLE_CLOUD_PROJECT/regions/us-central1/subnetworks/red-k8s-tutoriales \
        --set-secrets=POSTGRES_PASSWORD=medisupply_orders-postgres_password:latest \
        --set-env-vars=GOOGLE_CLOUD_PROJECT_ID=$GOOGLE_CLOUD_PROJECT,POSTGRES_USER=postgres,POSTGRES_HOST=192.168.0.3,POSTGRES_PORT=5432,POSTGRES_DB=postgres,REDIS_HOST=redis,REDIS_PORT=6379,REDIS_DB=0
elif [ "$1" == "order-projection-handler" ]; then
    echo "Deploying order-projection-handler"
    gcloud builds submit --region us-central1 --tag $ORDER_PROJECTION_HANDLER_IMAGE "$PROJECT_ROOT/src/queries/projection"
    # Deploy to Cloud Run
    gcloud run deploy order-projection-handler \
        --image $ORDER_PROJECTION_HANDLER_IMAGE \
        --allow-unauthenticated \
        --region us-central1 \
        --memory=1Gi \
        --cpu=1 \
        --max-instances=3 \
        --timeout=600s \
        --service-account=$SERVICE_ACCOUNT_EMAIL \
        --set-cloudsql-instances=$CLOUDSQL_INSTANCE_CONNECTION_NAME \
        --network=projects/$GOOGLE_CLOUD_PROJECT/global/networks/vpn-tutoriales-miso \
        --subnet=projects/$GOOGLE_CLOUD_PROJECT/regions/us-central1/subnetworks/red-k8s-tutoriales \
        --set-secrets=POSTGRES_PASSWORD=medisupply_orders-postgres_password:latest \
        --set-env-vars=GOOGLE_CLOUD_PROJECT_ID=$GOOGLE_CLOUD_PROJECT,POSTGRES_USER=postgres,POSTGRES_HOST=192.168.0.3,POSTGRES_PORT=5432,POSTGRES_DB=postgres
else
    echo "Building and pushing all images"
    gcloud builds submit --region us-central1 --config "$PROJECT_ROOT/src/commands/api/cloudbuild.yaml" "$PROJECT_ROOT/src/commands/api"
    gcloud builds submit --region us-central1 --tag $ORDER_COMMAND_HANDLER_IMAGE "$PROJECT_ROOT/src/commands/handlers"
    gcloud builds submit --region us-central1 --tag $ORDER_QUERY_API_IMAGE "$PROJECT_ROOT/src/queries/api"
    gcloud builds submit --region us-central1 --tag $ORDER_PROJECTION_HANDLER_IMAGE "$PROJECT_ROOT/src/queries/projection"
    # TODO: Deploy to Cloud Run
fi