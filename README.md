# bootstrapping

This repository contains R code for implementing the block bootstrap for ordinary least squares regression with clustered data. 

Existing packages in R implement a block bootstrap for time series data (for instance the 'tsboot' function in the 'boot' package) using blocks of fixed lengths. 

By contrast, this package allows the user to specify the block that will be resampled by specifying a factor variable. For example, the block might be a geographic area like a state or village, and the bootsrap function samples these blocks with replacement.

Output in this beta version includes a point estimate and confidence interval.
