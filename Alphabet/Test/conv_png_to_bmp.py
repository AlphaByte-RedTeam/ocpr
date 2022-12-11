import os
from PIL import Image

parent_dir = os.path.dirname(os.path.abspath(__file__))

DIR_PATH = "bmp"
# Create "bmp" directory
if not os.path.exists(DIR_PATH):
    os.makedirs(DIR_PATH)

# Loop through all the folders in the source directory
for file_name in os.listdir(parent_dir):
    # Check if the path is a dir
    if os.path.isdir(os.path.join(parent_dir, file_name)) and not file_name.endswith(".zip"):
        # Set the source and destination directories
        src_dir = os.path.join(parent_dir, file_name)
        dst_dir = src_dir

        # Create the destination directory if it doesn't exist'
        if not os.path.exists(dst_dir):
            os.makedirs(dst_dir)

        # Loop through all the files in the source directory
        for img_name in os.listdir(src_dir):
            # Check if the files is a PNG image
            if img_name.endswith(".png"):
                # Open the PNG image
                png_image = Image.open(os.path.join(src_dir, img_name))

                # Save the PNG image as a BMP image
                png_image.save(os.path.join(dst_dir, img_name.replace(".png", ".bmp")))
