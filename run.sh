#!/bin/bash

cd ./server

# Check if the 'venv' directory exists. If it doesn't, create it.
if [ ! -d "venv" ]; then
  echo "Virtual environment not found. Creating it now..."
  python -m venv venv
  pip install -r requirements.txt
  echo "Virtual environment 'venv' has been created."
fi

source ./venv/bin/activate

python main.py &
PYTHON_PID=$!
echo "Python server has started with PID: $PYTHON_PID"

open /Applications/Modifly.app
echo "Modifly has been opened."

# Loop until the Modifly app is no longer running
echo "Monitoring Modifly. The Python process will be killed when Modifly closes."
while pgrep -i -x "Modifly" > /dev/null; do
  sleep 5
done

# When the loop finishes (Modifly is closed), kill the Python process
kill $PYTHON_PID
echo "Modifly has been closed. The Python process with PID $PYTHON_PID has been killed."