function Image = load_images(fDPC,qDPC)
    % Check if the user correctly selected an imaging mode
    if fDPC == qDPC
        errordlg('Please select one method', 'Selection Error');
        return;
    end
    
    % Select folder
    folder = uigetdir('..\', 'Please select the folder containing TIFF images');
    
    % Check if user cancelled
    if folder == 0
        errordlg('Folder selection cancelled by user.', 'Selection Cancelled');
        return;
    end
    
    % Get all .tif files in the folder
    tif_files = dir(fullfile(folder, '*.tif'));
    
    
    % Check image count for fDPC
    if fDPC ==1
        if (length(tif_files) ~= 2 && length(tif_files) ~= 4)
            errordlg(sprintf('Please check the number of images. The current folder contains %d .tif files.', length(tif_files)), 'Incorrect Number of Images');
            return;
        end
    end
    
    if qDPC ==1
        if length(tif_files) ~= 4
            errordlg(sprintf('Please check the number of images. The current folder contains %d .tif files.', length(tif_files)), 'Incorrect Number of Images');
            return;
        end
    end
    
    % Read first image to get size
    first_image = imread(fullfile(folder, tif_files(1).name));
    [height, width] = size(first_image);
    
    % Create stack
    Image = zeros(height, width, length(tif_files));
    
    % Read all images into stack
    for i = 1:length(tif_files)
        temp_image = double(imread(fullfile(folder, tif_files(i).name)));
        if qDPC ==1
            tempImage = temp_image;
            Image(:, :, i) = tempImage/mean2(tempImage)-1;
        else
            Image(:, :, i) = temp_image;
        end
    end 
end