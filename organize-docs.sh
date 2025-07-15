#!/bin/bash

# Create docs directory structure
mkdir -p docs/deployment

# Move development documentation
if [ -f "DEVELOPMENT.md" ]; then
    mv DEVELOPMENT.md docs/development.md
    echo "✅ Moved DEVELOPMENT.md → docs/development.md"
fi

# Move deployment-related documentation
if [ -f "AWS_SETUP_CHECKLIST.md" ]; then
    mv AWS_SETUP_CHECKLIST.md docs/deployment/aws-setup.md
    echo "✅ Moved AWS_SETUP_CHECKLIST.md → docs/deployment/aws-setup.md"
fi

if [ -f "EC2_DEPLOYMENT_README.md" ]; then
    mv EC2_DEPLOYMENT_README.md docs/deployment/ec2-deployment.md
    echo "✅ Moved EC2_DEPLOYMENT_README.md → docs/deployment/ec2-deployment.md"
fi

if [ -f "DEPLOYMENT_SUMMARY.md" ]; then
    mv DEPLOYMENT_SUMMARY.md docs/deployment/deployment-summary.md
    echo "✅ Moved DEPLOYMENT_SUMMARY.md → docs/deployment/deployment-summary.md"
fi

if [ -f "FINAL_DEPLOYMENT_GUIDE.md" ]; then
    mv FINAL_DEPLOYMENT_GUIDE.md docs/deployment/final-guide.md
    echo "✅ Moved FINAL_DEPLOYMENT_GUIDE.md → docs/deployment/final-guide.md"
fi

echo ""
echo "🎉 Documentation organized! New structure:"
echo "├── README.md (main project)"
echo "├── docs/"
echo "│   ├── development.md"
echo "│   └── deployment/"
echo "│       ├── aws-setup.md"
echo "│       ├── ec2-deployment.md"
echo "│       ├── deployment-summary.md"
echo "│       └── final-guide.md"
echo "└── backend/README.md"
echo ""
echo "Root directory now only has README.md! 🧹"