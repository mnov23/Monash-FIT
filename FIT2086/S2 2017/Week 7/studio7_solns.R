####################################################################################
#	Script-file:   studio7_solns.R
#	Project:       FIT2086 - Studio 7
#
# Purpose:  	   Solutions for questions in Studio 7
####################################################################################

library(naivebayes)
library(pROC)

# ===========================================================================================
#
#                                       Question 2
#
# ===========================================================================================

rm(list=ls())


# -------------------------------------------------------------------------------------------
# 2.1
gene_train = read.csv("gene_train.csv", header=T)
levels(gene.train$Disease)
levels(gene.train$SNP2)


# -------------------------------------------------------------------------------------------
# 2.2
fullmod=glm(Disease ~ ., data=gene_train, family=binomial)
summary(fullmod)
# calculate AIC by hand ... confirm it matches
fullmod$null.deviance
fullmod$deviance
fullmod$deviance + 2*length(fullmod$coefficients)
# this matches the AIC reported using summary()


# -------------------------------------------------------------------------------------------
# 2.3
gene_test = read.csv("gene_test.csv")
prob = predict(fullmod, gene_test, type="response")
pred = factor(predict(fullmod,gene_test)>1/2, c(F,T), c("N","Y"))

# Generate a confusion matrix
table(pred, gene_test$Disease)
# We can see that our model doesn't do a great job of classifiying people
# it has rougly equal numbes of people correctly classified as diseased/non-diseased
# as it has people incorrectly classified


# -------------------------------------------------------------------------------------------
# 2.4
mean(pred == gene_test$Disease)
roc.fullmod = roc(response=as.numeric(gene_test$Disease)-1, prob)
roc.fullmod$auc
plot(roc.fullmod)

# The ROC curve and classification results confirm that the model is not good at 
# classifying people as diseased/undiseased, and is probably overfitting 
# Note that the ROC curve is not much different from the diagonal line (random guess)
# The model is not a good predictor of disease


# -------------------------------------------------------------------------------------------
# 2.5
source("my.prediction.stats.R")
my.pred.stats(prob, gene_test$Disease)
# note this produces all the statistics we calculated above by hand, plus a few more


# -------------------------------------------------------------------------------------------
# 2.6
# Prune out variables using stepwise regression
step.fit.aic = step(fullmod,direction="both")
summary(step.fit.aic)
my.pred.stats(predict(step.fit.aic,gene_test,type="response"), gene_test$Disease)

# AIC has removed a lot of variables but has not improved performance greatl;
# there are probably still too many unimportant variables included in the final model.
# AIC can be prone to adding too many variablesif the number of potential predictors is large.


# -------------------------------------------------------------------------------------------
# 2.7
step.fit.bic = step(fullmod, k = log(nrow(gene_train)), direction="both", trace = 0)
my.pred.stats(predict(step.fit.bic,gene_test,type="response"), gene_test$Disease)

# BIC has removed a lot of predictors, and left us with a model containing just two SNPs
# This model has greatly improved sensitivity (ability to detect people with disease).
# The specificity of our model (ability to detect non-diseased people) has not greatly improved.
# Overall classification accuracy is quite improved, and the log-loss has halved, meaning
# that our model estimates the probabilities of being diseased/undiseased substantially better
# The AUC curve bends "further away" from the diagonal line

# -------------------------------------------------------------------------------------------
# 2.8
summary(step.fit.bic)

#
# Our model is:
#
#   log-odds(Disease) = -0.1118 - 1.1343*SNP12Y + 1.4599*SNP56Y
#
# Having an SNP56 mutation increases our log-odds by 1.4599 (increase our risk of having disease).
# Having an SNP12 mutation decreases our log-odds by 1.1343 (decreases our risk of having the disease).
#
# So, having an SNP56 mutation increases our risk, and having a mutation at SNP12 is protective.
#
# Note: the "Y" after the variable names means that this is the coefficient associated with the predictor
# when it takes on the level "Y". If the predictor SNP12 had K levels instead of two, there would be
# (K-1) variables with the prefix name "SNP12".


# -------------------------------------------------------------------------------------------
# 2.9
nb = naive_bayes(Disease ~ ., data = gene_train)
pred = predict(nb,gene_test)
prob = predict(nb,gene_test,type="prob")
head(prob) # two columns -- first is prob of failure, second is prob of success
prob = predict(nb,gene_test,type="prob")[,2]   # gets just the prob. of success
my.pred.stats(prob, gene_test$Disease)

# The results are basically the same as the logistic regression using
# all the predictors in terms of all the predictive statistics
# Again, this model is overfitting


# -------------------------------------------------------------------------------------------
# 2.10
nb = naive_bayes(Disease ~ SNP12 + SNP56, data = gene_train)
prob = predict(nb,gene_test,type="prob")[,2]
my.pred.stats(prob, gene_test$Disease)

# Naive Bayes usually doesn't have direct model selection, but we can use the 
# variables selected by BIC when using logistic regression as a guide.
# In this case we end up with similar predictive performance and shape of AUC curve, 
# as the BIC logistic regression model, but a bit better log-loss, meaning the 
# naive Bayes model is doing a little better at predicting the probabilities of being
# diseased/undiseased.


# ===========================================================================================
#
#                                       Question 3
#
# ===========================================================================================

rm(list=ls())
library(naivebayes)
library(pROC)
source("my.prediction.stats.R")


# -------------------------------------------------------------------------------------------
# 3.1 
# Load the data
pima_train = read.csv("pima_train.csv")
fullmod = glm(DIABETES ~ . , data=pima_train, family=binomial)
summary(fullmod)

# From the p-values, it looks like PREG, PLAS, BP, BMI and PED
# are potentially associated, particularly PLAS and BMI.
# AGE is possibly associated as well as the p-value is in the 0.05 range.
# INS and SKIN appear to show no association


# -------------------------------------------------------------------------------------------
# 3.2 
pima_test = read.csv("pima_test.csv")
my.pred.stats(predict(fullmod,pima_test,type="response"),pima_test$DIABETES)

# This model performs quite well.
# The classification accuracy is reasonable, as is an AUC of 0.81
# This model  is better at identifying people without diabetes
# than it is at identyfing those people with diabetes
# ie., it has lower sensitivity and higher specificity.


# -------------------------------------------------------------------------------------------
# 3.3
# Prune
back.fit = step(fullmod, trace=0, k = log(668), direction="both")
my.pred.stats(predict(back.fit,pima_test,type="response"),pima_test$DIABETES)

# BIC has removed 4 variables, so the resulting model is quite a bit simpler.
# Classification accuracy is essentially the same, but the ROC curve improves
# and the logarithmic loss drops so this model is better at predicting the 
# probabilities of diabetes, even if the classification accuracy is not much better.


# -------------------------------------------------------------------------------------------
# 3.4
try.mod = glm(DIABETES ~ . + log(BMI), data = pima_train, family = binomial)
summary(fullmod)
summary(try.mod)

# BMI already appears associated in full model, and log(BMI) also appears
# to be quite strongly associated as well as the p-value is quite small
#
# Residual deviance of full model with all 8 predictors was 618.08, 
# and with log(BMI) this drops to 607 which is a large drop 
# (drops over 5 or 6 are starting to be "large")
#
# Note that BMI is a ratio, and logs of ratios can be more interpretable 
# as log(a/b) = -log(b/a), whereas a/b can be very different from b/a


# -------------------------------------------------------------------------------------------
# 3.5
try.mod = glm(DIABETES ~ . + I(PLAS^2), data = pima_train, family = binomial)
summary(try.mod)

# p-value is very large and the drop in deviance compared to the full
# model is only around 0.14. This is unlikely to be an important predictor


# -------------------------------------------------------------------------------------------
# 3.6
try.mod = glm(DIABETES ~ . + SKIN * AGE, data = pima_train, family = binomial)
summary(fullmod)
summary(try.mod)

# SKIN is not associated in the full model, and AGE is only marginally associated (0.05 < p < 0.1)
# The interaction appears to be more strongly associated (p < 0.05)
# Drop in residual deviance is around 5.16 which is starting to become substantial
# It is probable that this interaction is associated with DIABETES


# -------------------------------------------------------------------------------------------
# 3.7
# Fit a full model with all interactions, logs of all variables and squares of all variables
# Resulting model has 53 predictors.
fullmod = glm(DIABETES ~ . + .*. + log(PREG+1) + log(PLAS) + log(BP) + log(SKIN) + log(INS) + log(BMI) + log(PED) + log(AGE) 
              + I(PREG^2) + I(PLAS^2) + I(BP^2) + I(SKIN^2) + I(INS^2) + I(BMI^2) + I(PED^2) + I(AGE^2) , 
              data=pima_train, family=binomial)
my.pred.stats(predict(fullmod,pima_test,type="response"),pima_test$DIABETES)

# Including all these extra predictors has lead to a better model than we had before
# in terms of prediction onto our testing data. This suggests that some of the new predictors 
# we have included are very important, as this model does well despite having so many 
# predictors (and likely overfitting)

# Lets see if we can improve things by pruning
forward.fit.bic = step(fullmod, k = log(668), trace=0, direction="both")
summary(forward.fit.bic)
my.pred.stats(predict(forward.fit.bic,pima_test,type="response"),pima_test$DIABETES)

# This model is substantially simpler and performs better.
# Its residual deviance is 594.23 which is a big drop over the original model without the transformed variables (618.08)
# but it actually has less variables included (6) than the original "full model" which had 8
# This is quite suggestive that this is a better model of DIABETES

# Let's write down the regression model. To see coefficients more easily:
forward.fit.bic$coefficients

# The model equation is (with some rounding)
#
# log-odds(DIABETES) = -21.1 + 0.0364*PLAS - 0.02*BP + 0.342*AGE 
#                      + 3.157*log(BMI) - 0.0037*AGE^2 + 0.468*log(PED)
#
# We can't really change PLAS, and certainly cannot change AGE or the PED
# which is related to family history.
# We *can* reduce our BMI which, would reduce our probability of diabetes
#
# Our model suggests that a person's log-odds of diabetes decreases by 3.157
# per unit decrease in log-body mass index.


# -------------------------------------------------------------------------------------------
# 3.8
# here we use KIC, which penalises model a bit harder than AIC
# often preferred as is similar to AIC but less overfitting
forward.fit.kic = step(fullmod, k = 3, trace=0, direction="both")
summary(forward.fit.kic)
my.pred.stats(predict(forward.fit.kic,pima_test,type="response"),pima_test$DIABETES)

# This model predicts even better onto our testing data, but is quite a bit more complex than 
# the model selected by BIC.
# If all we care about is prediction, this model seems better; but the BIC model is a lot easier
# to understand for only a little less performance. It all depends on what you need
# the model for.
#
# If we compare to our BIC model, we see that in the model selected by KIC
# a persons log-odds of diabetes now decreases by 52.1 per unit decrease in
# log-body mass index. Although our model appears to predict a bit better
# this relationship seems likely to be overestimated. I would trust the etimates from
# simpler model a lot more.


# -------------------------------------------------------------------------------------------
# 3.9
nb = naive_bayes(DIABETES ~ ., data=pima_train)
prob = predict(nb,pima_test,type="prob")[,2]   # gets just the prob. of success
my.pred.stats(prob, pima_test$DIABETES)

# Naive Bayes is very quick to fit!
# The performance is not terrible, but the Naive Bayes model is clearly worse than
# all of the logistic regression models we have tried.
#
# This is likely because the conditional independence assumptions required
# by Naive Bayes do not hold in this population.
