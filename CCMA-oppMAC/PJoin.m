function p_join = PJoin(threshold)
%this function calculates the probability that clients will join the second
%contention
dx = 0.01;
x = 0:dx:1000;
temp = 0;
b = chi2pdf(x,4);
for i = 1:length(x)
    c = sqrt(threshold/x(i));
    if (c>1)
        a = pi/2;
    else
        a = asin(c);
    end
    temp = temp + 2*a/pi*b(i)*dx;
end
p_join = 1-temp;