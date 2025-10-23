# Define the coordinates (example data)
A_alpha <- 0.8; B_alpha <- 0.1  # 80% A, 10% B (alpha)
A_beta  <- 0.1; B_beta  <- 0.8  # 10% A, 80% B (beta)
A_gamma <- 0.1; B_gamma <- 0.1  # 10% A, 10% B (gamma)
A_P     <- 0.3; B_P     <- 0.4  # Bulk Point P

# ----------------------------------------------------------------------
# Function to calculate the area of a triangle given its three vertices
# ----------------------------------------------------------------------
triangle_area <- function(x1, y1, x2, y2, x3, y3) {
  # The factor of 0.5 can be omitted for fraction calculation since it cancels out.
  # We will use the unscaled absolute value of the determinant.
  return(abs(x1 * (y2 - y3) + x2 * (y3 - y1) + x3 * (y1 - y2)))
}

# ----------------------------------------------------------------------
# Ternary Lever Rule - Area Method Calculation
# ----------------------------------------------------------------------
calc_area_fractions <- function(p_coords, a_coords, b_coords, g_coords) {
  
  # Coordinates for clarity
  A_P <- p_coords[1]; B_P <- p_coords[2]
  A_alpha <- a_coords[1]; B_alpha <- a_coords[2]
  A_beta  <- b_coords[1]; B_beta  <- b_coords[2]
  A_gamma <- g_coords[1]; B_gamma <- g_coords[2]
  
  # 1. Calculate the area of the total tie-triangle (alpha-beta-gamma)
  TotalArea <- triangle_area(A_alpha, B_alpha, A_beta, B_beta, A_gamma, B_gamma)
  
  if (TotalArea == 0) {
    stop("The three apex points are collinear (on a straight line).")
  }
  
  # 2. Calculate the area of the sub-triangles (numerator for each phase)
  # f_alpha is proportional to the area of the triangle opposite alpha: P-beta-gamma
  Area_P_beta_gamma <- triangle_area(A_P, B_P, A_beta, B_beta, A_gamma, B_gamma)
  
  # f_beta is proportional to the area of the triangle opposite beta: P-alpha-gamma
  Area_P_alpha_gamma <- triangle_area(A_P, B_P, A_alpha, B_alpha, A_gamma, B_gamma)
  
  # f_gamma is proportional to the area of the triangle opposite gamma: P-alpha-beta
  Area_P_alpha_beta <- triangle_area(A_P, B_P, A_alpha, B_alpha, A_beta, B_beta)
  
  # 3. Calculate the fractions (ratio of areas)
  f_alpha <- Area_P_beta_gamma / TotalArea
  f_beta  <- Area_P_alpha_gamma / TotalArea
  f_gamma <- Area_P_alpha_beta / TotalArea
  
  return(list(
    f_alpha = f_alpha,
    f_beta = f_beta,
    f_gamma = f_gamma,
    sum_check = f_alpha + f_beta + f_gamma
  ))
}

# Run the calculation with example data
p_coords <- c(A_P, B_P)
a_coords <- c(A_alpha, B_alpha)
b_coords <- c(A_beta, B_beta)
g_coords <- c(A_gamma, B_gamma)

result_area <- calc_area_fractions(p_coords, a_coords, b_coords, g_coords)

# Output results
print("--- Results for Area Method (Option 2) ---")
print(paste("Fraction of alpha (f_alpha):", round(result_area$f_alpha, 4)))
print(paste("Fraction of beta (f_beta): ", round(result_area$f_beta, 4)))
print(paste("Fraction of gamma (f_gamma):", round(result_area$f_gamma, 4)))
print(paste("Sum of fractions check:  ", round(result_area$sum_check, 4)))