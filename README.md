# Tracking-health-and-body

The goal of this project is to examine several variables related to health and body composition from different diet and lifestyle factors. Machine learning algorithms will be used to learn and predict.

#### DATA COLLECTION ####
EXPORT MYFITNESSPAL: https://www.designbyvh.com/myfitnesspal-export-data/
EXPORT GOOGLE FIT: https://takeout.google.com/settings/takeout

#### VARIABLES ####

In order to be able to measure everything every day, the data should be easy to obtain. Objective measurements will probably be better to reduce statistical fluctuation. 

#### Health and lifestyle related variables ####
Weight					(weighting scale)
Bodyfat %				(weighting scale. large systemic error, but small statistical error)
Muscle %				(weighting scale. large systemic error, but small statistical error)
Waterweight %				(weighting scale. large systemic error, but small statistical error)
Resting heart rate morning 		(cell phone app)
Hours of sleep
Number of nocturnia
Hours of direct sunlight
Acne face (#yellow pimples)
Acne body (#yellow pimples)
Number/hours of naps during the day
Time spent on the internet		("mind the time" mozilla extension)
Number of times mastrubating/porn

#### Diet related variables ####
List with all the consumed foods and corresponding grams + full nutritional data per food item
-> From this list, Macro and micro nutrients can be calculated
-> other items like caffeine, alcohol, 

#### CAUSAL RELATIONS TO EXAMINE
Diet -> body composition (weight, bodyfat, muscle)
Lifestyle -> body composition
Diet -> acne

calories-> weight: broken linear function (see figure documentation) 
fats->muscle, fat: kwadratic, close to linear?
carbs->muscle, fat: kwadratic, close to linear?
protein->muscle, fat: kwadratic, close to linear?

#### MACHINE LEARNING ALGORITHM ####
??? which algorithm would be most appropriate?
From past experiments: Most foods take 1-2 days to take effect. 
time correlations?

For the most part, we expect linear effects. The amount of food or lifestyle factors will have linear

Expected: 





ADL MODEL: Auto Distributed Lag

assume x to be exogenuous. (x can be chosen: independent of other parameters of the model)

y_{t} = c + a*y_{t-1} + b_1*x_{t-1} + b_2*x_{t-2} + b_3*x_{t-3} + ... + epsilon_t

or more variables x to the model! set a = 1 (work in differences)?










