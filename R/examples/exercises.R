# =============================================================================
# Exercises for R Vectors
# a. Create and store a sequence of values from 5 to −11 that progresses
# in steps of 0.3.
# b. Overwrite the object from (a) using the same sequence with the
# order reversed.
# c. Repeat the vector c(-1,3,-5,7,-9) twice, with each element
# repeated 10 times, and store the result. Display the result sorted
# from largest to smallest.
# d. Create and store a vector that contains, in any configuration, the
# following:
# i. A sequence of integers from 6 to 12 (inclusive)
# ii. A threefold repetition of the value 5.3
# iii. The number −3
# iv. A sequence of nine values starting at 102 and ending at the
# number that is the total length of the vector created in (c)
# e. Confirm that the length of the vector created in (d) is 20.
# ================================================================================
# a.
vec_a <- seq(5, -11, by = -0.3)
cat("Vector a:\n")
print(vec_a)
cat("\n")
# b.
vec_b <- rev(vec_a)
cat("Vector b (reversed):\n")
print(vec_b)
cat("\n")
# c.
vec_c <- rep(c(-1, 3, -5, 7, -9), each = 10, times = 2)
vec_c_sorted <- sort(vec_c, decreasing = TRUE)
cat("Vector c (sorted):\n")
print(vec_c_sorted)
cat("\n")
# d.
vec_d <- c(6:12, rep(5.3, 3), -3, seq(102, length(vec_c_sorted), length.out = 9))
cat("Vector d:\n")
print(vec_d)
cat("\n")
# e.
length_d <- length(vec_d)
cat("Length of vector d:", length_d, "\n")