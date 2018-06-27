# Computer Vision Assignments

These are my solutions to the assignments for the computer vision class in SS2018 at TU Munich. All assignments were to be done in Matlab, using only its standard features (no toolboxes allowed).

All code comments are currently in german language since the course was teached in german. I'm aiming to translate them soon.

## Assignment 1
The key objective for the first assignment was to make an implementation of the harris feature detector. This algorithm is commonly used to detect corners in pictures that are subsequently used for correspondence estimation between different pictures of the same scene.

## Assignment 2
The harris detector from assignment 1 provides us with a set of corner features for a given grayscale image. The aim for assignment 2 is to use two different pictures of the same scene (left and right point of views) and estimate feature affinity, based on the normalised cross correlation algorithm, in order two find pairs of corresponding features.

Finding corresponding pixels is the key for application of stereo algorithms, that enable three-dimensional computer vision.

## Assignment 3
After corresponding pixels have been found in the previous assignment, Assignment 3 focuses on extracting plausible / robust members from this set.

This is acomplished using an algorithm derived from the class of *random sample consensus* (RanSaC) algorithms. The algorithm uses the *eight-point algorithm* to compute an estimate of the scenes *fundamental matrix* F (expresses the relative positions of both camera views on the scene) and builds a set that is coherent regarding F and thus matches the perceived relation between the camera viewpoints. The important metric function used to calculate the coherence of the set is the *sampson distance*.

We finally calculate the scenes *essential matrix* E using the robust corresponding pixels and the *camera parameter matrix* K to adjust the images by removing lens and sensor induced distortion.

## Assignment 4
The fourth and last set of tasks was all about 3D scene reconstruction which was the ultimate goal of the course.

We take the estimated essential matrix from assignment 3 and derive the four matching coordinate transformations denoted by their Ts and Rs. We use R and T and build a set of linear equations that depicts the relation between corresponding points, their depths and the connecting coordinate transformation. The solution vector contains the depth of all correspondence points and a scaling factor gamma for the translation T that we used. This scaling exists because we can't tell the difference between a large distant object or one that is small and close by. We scale the vector to gamma = 1 and can forget about it then. The solution vector with the largest number of positive depths is considered the best and kept. The final step is to take this vector, reconstruct the room coordinates of correspondence points in image 1, project them onto camera plane 2 - using R and T to the best solution vector - and compare them to the "original" correspondence points in image 2. We calculate the mean reprojection error which gives us a measure for the quality of our estimate of E and the depths.

Thats it, no more assignments.
