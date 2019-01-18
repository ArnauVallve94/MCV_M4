function [disparity] = stereo_computation(left_im, right_im, minDisp, maxDisp, ws, mc)
% input : 
% - left image
% - right image
% - minimum disparity
% - maximum disparity
% - window size (e.g. a value of 3 indicates a 3x3 window)
% - matching cost (the user may able to choose between SSD and NCC costs)
%
    disparity = zeros(size(left_im));    
    [h,w] = size(left_im);
    
    pad = floor(ws/2);
    
    left_im = padarray(left_im, [pad pad]);
    right_im = padarray(right_im, [pad pad]);
    
    for i=1+pad:(h + pad)
        for j=1+pad:(w + pad)
            left_patch = double(left_im((i - pad):(i + pad), (j - pad):(j + pad)));
            % size(leftPatch)
            minCol = max((1 + pad), (j - maxDisp));
            maxCol = min((w + pad), (j + maxDisp));
            
            % define window weight
            weight = zeros(size(left_patch));
            weight(:) = 1/(prod(size(left_patch)));
                
            if strcmp(mc, 'SSD')
                bestSSD = Inf; 
                for k = minCol:maxCol
                    right_patch = double(right_im(i-pad:i+pad, k-pad:k+pad));
                    ssd = sum(sum( weight.*(left_patch-right_patch).^2 ));
                    if ssd < bestSSD
                        bestSSD = ssd;
                        best = k;
                    end
                end
            end
            if strcmp(mc, 'NCC')
                bestNCC = -Inf;                
                for k = minCol:maxCol
                    right_patch = double(right_im(i-pad:i+pad, k-pad:k+pad));
                    sum_left = sum(left_patch(:).*weight(:));
                    sum_right = sum(right_patch(:).*weight(:));
                    
                    sigma_left = sqrt(sum( weight(:).* (left_patch(:) - sum_left).^2 ));
                    sigma_right = sqrt(sum( weight(:).* (right_patch(:) - sum_right).^2 ));
                    
                    ncc = sum( weight(:).*(left_patch(:)-sum_left).*(right_patch(:)-sum_right) )/(sigma_left*sigma_right);
                    if ncc > bestNCC
                        bestNCC = ncc;
                        best = k;
                    end
                end
            end
            disparity(i-pad, j-pad) = abs(j-best);
        end        
    end
    a=1;
end
