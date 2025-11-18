#!/bin/bash

# 🚀 Notification System v2.0 - Firebase Deployment Script
#
# Deploys all Firebase components for notification system v2.0:
# - Firestore security rules
# - Firestore indexes (3 composite indexes)
# - Cloud Functions (3 functions)
#
# Usage:
#   ./firebase/deploy_notification_v2.sh [--dry-run] [--project PROJECT_ID]
#
# Options:
#   --dry-run       Preview changes without deploying
#   --project ID    Specify Firebase project ID (default: from .firebaserc)

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Parse arguments
DRY_RUN=false
PROJECT_ID=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --project)
      PROJECT_ID="$2"
      shift 2
      ;;
    *)
      echo -e "${RED}Unknown option: $1${NC}"
      exit 1
      ;;
  esac
done

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🚀 Notification System v2.0 - Firebase Deployment${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Step 0: Check Firebase CLI installed
if ! command -v firebase &> /dev/null; then
    echo -e "${RED}❌ Firebase CLI not found!${NC}"
    echo -e "${YELLOW}Install with: npm install -g firebase-tools${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Firebase CLI installed${NC}"

# Step 1: Check authentication
if ! firebase projects:list &> /dev/null; then
    echo -e "${RED}❌ Not authenticated with Firebase!${NC}"
    echo -e "${YELLOW}Run: firebase login${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Firebase authenticated${NC}"

# Step 2: Select project
if [ -n "$PROJECT_ID" ]; then
    firebase use "$PROJECT_ID" || exit 1
    echo -e "${GREEN}✅ Using project: $PROJECT_ID${NC}"
else
    CURRENT_PROJECT=$(firebase use 2>&1 | grep "Active project" | awk '{print $4}' || echo "none")
    echo -e "${YELLOW}📋 Current project: $CURRENT_PROJECT${NC}"
    echo -e "${YELLOW}To change: ./deploy_notification_v2.sh --project YOUR_PROJECT_ID${NC}"
fi

echo ""

# Step 3: Dry-run check
if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}🔍 DRY-RUN MODE - No actual deployment${NC}"
    echo ""
fi

# Step 4: Deploy Firestore Security Rules
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}📜 Step 1/3: Deploying Firestore Security Rules${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}[DRY-RUN] Would deploy: firebase/firestore_security_rules_v2.rules${NC}"
else
    # Copy rules to firestore.rules (Firebase expects this filename)
    cp firebase/firestore_security_rules_v2.rules firestore.rules

    firebase deploy --only firestore:rules

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Security rules deployed successfully${NC}"
    else
        echo -e "${RED}❌ Security rules deployment failed${NC}"
        exit 1
    fi
fi

echo ""

# Step 5: Deploy Firestore Indexes
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🗂️  Step 2/3: Deploying Firestore Indexes${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}[DRY-RUN] Would deploy 3 composite indexes:${NC}"
    echo -e "${YELLOW}  - notificationHistory (timestamp ASC)${NC}"
    echo -e "${YELLOW}  - notificationHistory (type ASC, timestamp DESC)${NC}"
    echo -e "${YELLOW}  - notificationHistory (isRead ASC, timestamp DESC)${NC}"
else
    firebase deploy --only firestore:indexes

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Indexes deployed successfully${NC}"
        echo -e "${YELLOW}⏳ Note: Index building may take 5-10 minutes${NC}"
        echo -e "${YELLOW}   Check status: firebase firestore:indexes${NC}"
    else
        echo -e "${RED}❌ Indexes deployment failed${NC}"
        exit 1
    fi
fi

echo ""

# Step 6: Deploy Cloud Functions
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}⚡ Step 3/3: Deploying Cloud Functions${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}[DRY-RUN] Would deploy 3 Cloud Functions:${NC}"
    echo -e "${YELLOW}  - notificationCleanup (scheduled daily at 2:00 AM UTC)${NC}"
    echo -e "${YELLOW}  - testNotificationCleanup (manual test function)${NC}"
    echo -e "${YELLOW}  - deleteUserNotificationData (GDPR deletion)${NC}"
else
    # Check if functions directory exists
    if [ ! -d "firebase/functions" ]; then
        echo -e "${RED}❌ firebase/functions directory not found${NC}"
        exit 1
    fi

    # Install dependencies if needed
    if [ ! -d "firebase/functions/node_modules" ]; then
        echo -e "${YELLOW}📦 Installing Cloud Functions dependencies...${NC}"
        cd firebase/functions && npm install && cd ../..
    fi

    firebase deploy --only functions:notificationCleanup,functions:testNotificationCleanup,functions:deleteUserNotificationData

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Cloud Functions deployed successfully${NC}"
        echo ""
        echo -e "${YELLOW}📋 Deployed functions:${NC}"
        echo -e "${YELLOW}  1. notificationCleanup (scheduled)${NC}"
        echo -e "${YELLOW}     - Runs daily at 2:00 AM UTC${NC}"
        echo -e "${YELLOW}     - Deletes old notification history per user retention settings${NC}"
        echo -e "${YELLOW}  2. testNotificationCleanup (HTTP)${NC}"
        echo -e "${YELLOW}     - Test cleanup logic without deleting data${NC}"
        echo -e "${YELLOW}     - curl https://YOUR_REGION-YOUR_PROJECT.cloudfunctions.net/testNotificationCleanup${NC}"
        echo -e "${YELLOW}  3. deleteUserNotificationData (callable)${NC}"
        echo -e "${YELLOW}     - GDPR Article 17 deletion${NC}"
        echo -e "${YELLOW}     - Called from Flutter app${NC}"
    else
        echo -e "${RED}❌ Cloud Functions deployment failed${NC}"
        exit 1
    fi
fi

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Deployment Complete!${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if [ "$DRY_RUN" = false ]; then
    echo -e "${GREEN}🎉 Notification System v2.0 Firebase components deployed!${NC}"
    echo ""
    echo -e "${YELLOW}📋 Next Steps:${NC}"
    echo -e "${YELLOW}  1. Verify indexes are building:${NC}"
    echo -e "${YELLOW}     firebase firestore:indexes${NC}"
    echo -e "${YELLOW}  2. Test security rules in Firebase Console${NC}"
    echo -e "${YELLOW}  3. Test Cloud Functions:${NC}"
    echo -e "${YELLOW}     curl https://YOUR_REGION-YOUR_PROJECT.cloudfunctions.net/testNotificationCleanup${NC}"
    echo -e "${YELLOW}  4. Check Cloud Scheduler job created:${NC}"
    echo -e "${YELLOW}     gcloud scheduler jobs list${NC}"
    echo ""
    echo -e "${YELLOW}📚 Documentation:${NC}"
    echo -e "${YELLOW}  - Deployment Guide: firebase/DEPLOYMENT_GUIDE.md${NC}"
    echo -e "${YELLOW}  - Integration Checklist: docs/features/notifications/INTEGRATION_CHECKLIST.md${NC}"
    echo ""
else
    echo -e "${YELLOW}🔍 Dry-run complete - no actual deployment performed${NC}"
    echo -e "${YELLOW}Remove --dry-run to deploy for real${NC}"
fi

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
