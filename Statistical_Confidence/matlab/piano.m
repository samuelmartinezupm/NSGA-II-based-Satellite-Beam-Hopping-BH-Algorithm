
function [y1,y2,y3,y4]=piano(theta,a,w,b,h)

	y1 = (a*cos(theta)-w)./sin(theta);
	y2 = b+(a*cos(theta)-w)./sin(theta);
	y3 = (h-a*sin(theta))./cos(theta);
	y4 = b+(h-a*sin(theta))./cos(theta);

end


