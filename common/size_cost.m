function [s_cost,s_prob] = size_cost(size1,size2)

w1 = size1(1);
h1 = size1(2);

w2 = size2(1);
h2 = size2(2);

s_prob = 1-(abs(w1-w2)/(w1+w2) + abs(h1-h2)/(h1+h2))/2;
s_cost = -log(exp(-(abs(w1-w2)/(w1+w2) + abs(h1-h2)/(h1+h2))));% template size similarity
% size_cost = (exp(-(abs(w1-w2)/(w1+w2) + abs(h1-h2)/(h1+h2))));% template size similarity



