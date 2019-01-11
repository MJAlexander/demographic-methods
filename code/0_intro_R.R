## Demographic Methods
## Week 1
## Monica Alexander
## Very intro to R

# add things
1+2

# multiply things
2*3

# assign values to variables
x <- 1
y <- 2
x+y

# variables can be strings too
first_name <- "Monica"
last_name <- "Alexander"

paste(first_name, last_name, sep = " ")

# paste is a function built into R, which takes a series of arguments and returns output
# another example function is c(), which lets you define vectors

z <- c(1,2,3,5,1,7)
z

# we can do scalar operations on vectors
z*0.5

# we can also add two vectors 
z+z

#### Matrices

# the matrix function lets you define matrices

A <- matrix(data = 1:16, ncol = 4, nrow = 4)
A

# you can look at various characteristics of A

is.matrix(A) # returns TRUE if A is a matrix
dim(A)  # returns a vector with dimensions of A (nrow, ncol)
ncol(A) # number of columns of A
nrow(A) # number of rows of A

# Matrices can be subset by using square brackets and the row and/or column indicies:

A[2,1] # returns element in second row and first column 
A[,3] # returns third column
A[4,] # returns fourth row

# There are some handy built-in matrix functions, for example:
colSums(A) # returns a vector of sums of each column of A
rowMeans(A) # returns a vector of means of each row of A
t(A) # transpose of A
diag(A) # returns a vector with just the diagonal elements of A
eigen(A) # returns a list eigenvalues and eignvectors of A


# Provided the matrices are conformable, matrix multiplication is performed through the use of `%*%` function.

B <- matrix(data = rep(1, 16), nrow = 4, ncol = 4)
B

A%*%B

### For loops

# For loops repetitively execute a statement or series of statements until a condition isn't true. 
# Loops are useful because they save us from copy-pasting similar code over and over.

for(i in 1:10){
  print(paste("Hello, you are in loop number", i))
}

