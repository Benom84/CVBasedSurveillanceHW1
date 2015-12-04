function plotGaussian(rangeMin, rangeMax, step, mu, sigma, color)
% Plot gaussian
% Input: rangeMin - min of x
%    	 rangeMax - max of x
%        step - step between rangeMin and rangeMax
%        mu - expectation of the gaussian distribution
%        sigma - standard deviation of the gaussian distribution
%        color - the color of the plot. e.g., 'b' for blue, 'g' for green,
%        'r' for red (see built-in function 'plot')
    meshXArr = rangeMin:step:rangeMax;
    gaussianValueArr = (1/(2*pi*sigma^2))*exp(-((meshXArr-mu).^2/(2*sigma^2)));
    
    hold on;
    plot(meshXArr, gaussianValueArr, color);
    xlabel('x');
    ylabel('G(x,mu,sigma)');
    hold off;

end

