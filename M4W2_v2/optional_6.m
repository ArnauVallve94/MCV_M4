% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% 6. OPTIONAL: Detect the UPF logo in the two UPF images using the 
% %%              DLT algorithm (folder "logos").
% %%              Interpret and comment the results.
% 
%% Open images
clear all; close all;
imargb = imread('Data/logos/logoUPF.png');
%imbrgb = imread('Data/logos/UPFstand.jpg');
imbrgb = imread('Data/logos/UPFbuilding.jpg');

ima = sum(double(imargb), 3) / 3 / 255;
imb = sum(double(imbrgb), 3) / 3 / 255;

%% Compute SIFT keypoints
[points_a, desc_a] = sift(ima, 'Threshold', 0.01);
[points_b, desc_b] = sift(imb, 'Threshold', 0.01);

figure;
imshow(imargb);%image(imargb)
hold on;
plot(points_a(1,:), points_a(2,:),'+y');
figure;
imshow(imbrgb);%image(imbrgb);
hold on;
plot(points_b(1,:), points_b(2,:),'+y');

%% Match SIFT keypoints 

% between a and b
matches_ab = siftmatch(desc_a, desc_b);
figure;
plotmatches(ima, imb, points_a(1:2,:), points_b(1:2,:), matches_ab, 'Stacking', 'v');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 2. Compute the homography (DLT algorithm) between image pairs

%% Compute homography (normalized DLT) between a and b, play with the homography
th = 3;
xab_a = [points_a(1:2, matches_ab(1,:)); ones(1, length(matches_ab))];
xab_b = [points_b(1:2, matches_ab(2,:)); ones(1, length(matches_ab))];
[Hab, inliers_ab] = ransac_homography_adaptive_loop(xab_a, xab_b, th, 1000); % ToDo: complete this function --> done

figure;
plotmatches(ima, imb, points_a(1:2,:), points_b(1:2,:), ...
    matches_ab(:,inliers_ab), 'Stacking', 'v');

vgg_gui_H(imargb, imbrgb, Hab);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 3. Show detected logo
im_sz = size(imb);
corners = [1 im_sz(2) 1 im_sz(1)];
H = eye(3);                             % --> done homography = 1 0 0; 0 1 0; 0 0 1
iwb = apply_H_v2(imbrgb, H, corners);   % ToDo: complete the call to the function 

H = Hab;                                % --> done Hab = ransac/homography2d(xab_a, xab_b)
iwa = apply_H_v2(imargb, H, corners);   % ToDo: complete the call to the function 

mask = imbinarize(iwa(:,:,1),0);
st = regionprops(mask, 'BoundingBox', 'Area' );
thisBB = st.BoundingBox;

figure;
imshow(iwb);
hold on;
rectangle('Position', [thisBB(1),thisBB(2),thisBB(3),thisBB(4)],...
  'EdgeColor','g','LineWidth',2 )
title('Mosaic A-B-C');