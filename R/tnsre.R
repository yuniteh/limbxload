library(lme4)
library(nlme)
library(emmeans)
library(pbkrtest)

dat <- read.csv("Z:/Lab Member Folders/Yuni Teh/projects/limbxload/matlab/test.csv")
met <- dat$stop

dat$pos <- factor(dat$pos)
dat$sub <- factor(dat$sub)
dat$ld <- factor(dat$ld)

contrasts(dat$pos) = contr.sum(4)
contrasts(dat$ld) = contr.sum(3)

print('-------------EFFECTS CODING------------')
mod <- lmer(met~pos+ld+pos*ld+(1|sub),data = dat)
print(summary(mod))
print(anova(mod))

emm <- emmeans(mod,"ld")
print(contrast(emm))
print(pairs(emm))

contrasts(dat$pos) = contr.treatment(4)
contrasts(dat$ld) = contr.treatment(3)

print('-------------REFERENCE CODING-------------')
# mod <- lmer(met~pos+ld+pos*ld+(1|sub),data = dat)
# print(summary(mod))
# print(anova(mod))
# 
# emm <- emmeans(mod,"pos")
# print(contrast(emm))
# print(pairs(emm))
