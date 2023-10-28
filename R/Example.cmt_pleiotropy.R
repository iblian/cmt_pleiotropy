library(readxl)
gout <- read_excel("C:/Users/User-Name/Downloads/gout.xlsx")
result <- cmt_pleiotropy(outcome="gout",
                         exposure="bmi",
                         G=colnames(gout)[-c(1,12)],
                         data=gout,
                         Bootstrap_times = 100, prop = 0.8)
result