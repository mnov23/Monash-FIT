####################################################################################
#	Script-file:   studio5_solns.R
#	Project:       FIT2086 - Studio 5
# Author:        Daniel Schmidt
#
# Purpose:  	   Solutions for questions in Studio 5
####################################################################################

# ----------------------------------------------------------------------------------
# Question 2
# ----------------------------------------------------------------------------------

# Q2.4
bpdata = read.csv("bpdata.csv")

# Q2.5
# Use the t.test() function; the mu argument specifies the hypothesis value of
# the population mean (i.e., mu_0 in our notes)
t.test(x=bpdata$BP, mu=120)

# p-value is 9 x 10^-5, so very strong evidence against the null which is that our
# population is an ``at risk'' population.

# Q2.6
# Again use the t.test() function, but now use a different alternative
t.test(x=bpdata$BP, mu=120, alternative="less")

# p-value is now 4.5 x 10^-5, so very strong evidence against the null. Our null is
# now that our sample comes from a population that is neither at risk, nor has high blood pressure,
# i.e. they are healthy.

# 2.8
# Interval gets wider as conf.level gets closer to 1
t.test(x=bpdata$BP, mu=120, conf.level=0.95)
t.test(x=bpdata$BP, mu=120, conf.level=0.99)
t.test(x=bpdata$BP, mu=120, conf.level=0.999)


# ----------------------------------------------------------------------------------
# Question 3
# ----------------------------------------------------------------------------------

# Q3.1
SP500 = read.csv("SP500.csv")

# Plot the data -- it is clear there is a big difference so we do expect small p-value
plot((SP500$Index), type="l", xlab="Week since 7th September, 2007", ylab="S&P Index", lwd=2.5)
lines(x=59:108,y=SP500$Index[59:108], col="red", lwd=2.5)

# Relevant statistics, calculated last week (see Studio 4 solution)
mu_pre  = 1381.703
mu_post = 886.916

sigma2_pre  = 9383.026
sigma2_post = 7002.371

n_pre  = 58
n_post = 50

# Approximate test for difference of means with unknown variances
diff = mu_pre - mu_post
se_diff = sqrt(sigma2_pre/n_pre + sigma2_post/n_post)

# the standard error of 17.37 is quite small compared to the observed difference of 494 --
# i.e., the difference is large relative to the variability in our estimate, so it will
# offer strong evidence against the null that the population difference is zero (i.e. the S&P
# index before and after the collapse is the same)

z = diff/se_diff
p = 2*pnorm(-abs(z))

# The p-value is incredibly tiny -- not unsurprising given how the data looks when we plot it

# Q3.2
y_pre = SP500$Index[1:58]
y_post = SP500$Index[59:108]

# Q3.2.i
t.test(y_pre, y_post, var.equal = F)

# p-value is again tiny -- R just reports < 2e-16 in the case the p-value is smaller than that
# because very small p-values are hard to interpret
#
# you can get the exact p-value using something like
rv = t.test(y_pre, y_post, var.equal=F)
rv$p.value
# t.test returns a lot of information you can get access to

t.test(y_pre, y_post, var.equal = T)

# the p-values are all essentially the same as the difference is so enormous. 
# the confidence intervals vary a little with the approximate CI of (460.735, 528.838)
# being the narrowest (and therefore, a little "overconfident") because we did not take
# into account the variability in our estimate of the variances.
#
# assuming the variances are the same leads to a little wider interval in this case,
# likely because the variances are quite different: 7002 vs 9383.


# ----------------------------------------------------------------------------------
# Question 4
# ----------------------------------------------------------------------------------

# Q4.1
mx = 4
nx = 12
theta_hat_x = mx/nx

# Testing against theta = 1/2 (fair coin)
theta_0 = 1/2

z = (theta_hat_x - theta_0) / sqrt(theta_0*(1-theta_0)/nx)
p = 2*pnorm(-abs(z))

p

# p-value is 0.25, which means that if we our coin was fair, and we tossed it n=12 times
# then 25% of the time these 12 throws would have mx <= 4 OR mx >= 8 heads (i.e., be
# biased towards heads or tails by the amount observed in our sample). This is not strong
# evidence against the null.

# Q4.2
# the exact procedure is based on the binomial distribution.
binom.test(x = mx, n = nx, p = 1/2)

# the exact p-value is 0.3877, which is a bit bigger than our approximate procedure, but gives
# the same overall conclusion. If the sample size nx was larger we would expect the two
# p-values to be closer, as the normal approximation on which our approximate method is based
# would be better

# Q4.3
binom.test(x = 3, n = nx, p = 1/2)
# p-value of 0.146, still not strong evidence

binom.test(x = 2, n = nx, p = 1/2)
# p-value of 0.0385, so start to be unlikely to see this much bias in 12 throws of a 
# fair coin just by chance. So for mx=2 or mx=10 heads we would start to question the coin.

# Q4.4
my = 10
ny = 12
theta_hat_y = my/ny
theta_p = (mx+my)/(nx+ny)

theta_hat_x - theta_hat_y
# difference is -0.5, which is quite large

z = (theta_hat_x - theta_hat_y)/sqrt(theta_p*(1-theta_p)*(1/nx+1/ny))
p = 2*pnorm(-abs(z))
p

# p-value is 0.0129; so if we repeated the experiment and the coin had not been changed,
# then 1 out of 77 tosses of n = nx+ny = 24 coins would result in a difference as great as 
# we observed, or greater, just by chance. This would lead us to believe that the coin
# was different between the two sequences of coin tosses.

# Q4.5
prop.test(x = c(mx,my), n = c(nx,ny))

# p-value of more exact test is 0.0384; or about 1 in 26 times we would expect
# to see a difference as great, or greater than the one we observed just by chance, if the
# coin was the same for both groups. This is weaker evidence against the null than
# the approximate test (the approximate test is a overstating the evidence), but
# would still lead us to believe the coin was different between the two series of tosses.