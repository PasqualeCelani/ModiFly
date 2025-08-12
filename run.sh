#!/bin/bash

cd ../server
source ./venv/bin/activate

python main.py &
PYTHON_PID=$!
echo "Python server has start!"

open /Applications/Modifly.app
echo "Modifly has open!"

# Loop until the Modifly app is no longer running
echo "Monitoring Modifly. The Python process will be killed when Modifly closes"
while pgrep -f -x "Modifly" > /dev/null; do
  sleep 5
done

# When the loop finishes (Modifly is closed), kill the Python process
kill $PYTHON_PID
echo "Modifly has been closed. The Python process with PID $PYTHON_PID has been killed."