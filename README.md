# Computer Vision Assignments

These are my solutions to the assignments for the computer vision class in SS2018 at TU Munich. All assignments are to be done in Matlab, using only its standard features.

## Assignment 1
The key objective for the first assignment was to make an implementation of the harris feature detector. This algorithm is commonly used to detect corners in pictures that are subsequently used for correspondence estimation between different pictures of the same scene.

## Assignment 2
The harris detector from assignment 1 provides us with a set of corner features for a given grayscale image. The aim for assignment 2 is to use two different pictures of the same scene (left and right point of views) and estimate feature affinity, based on the normalised cross correlation algorithm, in order two find pairs of corresponding features.

Finding corresponding pixels is the key for application of stereo algorithms, that enable three-dimensional computer vision.

## Assignment 3
After corresponding pixels have been found in the previous assignment, Assignment 3 focuses on extracting plausible / robust members from this set.

This is acomplished using an algorithm derived from *random sample consensus* (RanSaC) algorithms. The algorithm uses the *eight-point algorithm* to compute an estimate of the scenes *fundamental matrix* F (expresses the relative positions of both camera views on the scene) and builds a set that is coherent regarding F and thus matches the perceived relation between the camera viewpoints. The important metric function used to calculate the coherence of the set is the *sampson distance*.

We finally calculate the scenes *essential matrix* E using the robust corresponding pixels and the *camera parameter matrix* K to adjust the images by removing lens and sensor induced distortion.

## Assignment 4
**TO-DO:**
* Write description for assignment 4
