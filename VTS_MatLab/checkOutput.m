function kladfunctie(signal)
hold on
dims = size(signal);
fingers = dims(2);
for finger = 1:fingers
    plot(signal(:, finger));
end
end
