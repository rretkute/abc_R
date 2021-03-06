# Load in model functions
source('case_1_preamble.R')

# Read in data file
D <- read.csv(file.path("..", "data", "data.csv"))

# What was the last day of the epidemic
t_final<-20

# Extract final size
final_size<-D[t_final,2]
mu_1<-final_size

# Extract number of infected people at the end the epidemic (0)
mu_2<-D[t_final,1]


#### ABC set up #### 
# Number of particles
N <- 1000

# Epsilon value
epsilon <- 2

# Empty matrix to store results (3 model parameters and the distance )
res<-matrix(ncol=4,nrow=N)
colnames(res)<-c('S_0','beta','gamma','distance')
# With correct number of rows

#### ABC algoirthm ####

#Initiate counter
i<-1

while(i <= N){ # While the number of accepted particles is less than N_particles
  
  # Sample from prior distributions 
  S0_star<-rpois(1,100)
  beta_star<-runif(1,0,3)
  gamma_star<-runif(1,0.,0.4)
  
  # Simulate data set from the model
  D_star<-run_model(S0_star,beta_star,gamma_star)
  
  # Calculate summary statistic
  mu_1_star<-summary_stat(D_star[,2])
  mu_2_star<-summary_stat(D_star[,1])
  
  # Calculate distance  
  distance <- calc_distance_final_size(mu_1, mu_1_star)+calc_distance_final_size(mu_2, mu_2_star)
  
  if(distance <= epsilon){ # If the distance is less than the tolerance
    # Store results
    res[i,]<-c(S0_star,beta_star,gamma_star,distance)
    
    # Update counter
    print(i)
    i <- i+1
  }
}
# Save data to disk
write.csv(res,'ABC_3_res.csv',row.names = F)
