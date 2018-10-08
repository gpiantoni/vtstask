function test_serial_port()
%TEST_SERIAL_PORT sends code '100' every 500 ms

s = serial('COM5');
fopen(s);

while 1
    fprintf(s, '%c', 100);
    pause(0.5)
end

fclose(s);