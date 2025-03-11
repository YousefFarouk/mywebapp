#!/bin/bash
echo "Running tests..."
npm test
if [ $? -ne 0 ]; then
    echo "Tests failed."
    exit 1
fi
echo "All tests passed."
