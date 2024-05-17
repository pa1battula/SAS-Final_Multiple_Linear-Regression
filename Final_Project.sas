                           **Multiple Linear Regression;

** section1;
** importing raw data from CSV file;
data electric;
infile "/home/u63733657/STAT-SAS/Final_project/ElectricCarData_Clean.csv" dlm ="," firstobs=2 ;
length PowerTrain $9. TopSpeed_KmH 8.	Range_Km 8. Efficiency_WhKm 8. BodyStyle $9.;
input PowerTrain $ TopSpeed_KmH	Range_Km Efficiency_WhKm BodyStyle $ PriceEuro;
run;

** Check the data;
proc print data=electric;
run;


** section2;
** Exploratory Data Analysis;
** Scatter plot for TopSpeed_KmH vs. PriceEuro with linear regression line;
proc sgplot data=electric;
    scatter x=TopSpeed_KmH y=PriceEuro / markerattrs=(symbol=circlefilled color=white);
    reg x=TopSpeed_KmH y=PriceEuro / lineattrs=(color=purple);
    xaxis label="Top Speed (Km/H)";
    yaxis label="Price (Euro)";
    title "Top Speed vs. Price with Linear Regression Line";
run;
** Scatter plot for Range_Km vs. PriceEuro with linear regression line;
proc sgplot data=electric;
    scatter x=Range_Km y=PriceEuro / markerattrs=(symbol=circlefilled color=black);
    reg x=Range_Km y=PriceEuro / lineattrs=(color=red);
    xaxis label="Range (Km)";
    yaxis label="Price (Euro)";
    title "Range vs. Price with Linear Regression Line";
run;
** Scatter plot for Efficiency_WhKm vs. PriceEuro with linear regression line;
proc sgplot data=electric;
    scatter x=Efficiency_WhKm y=PriceEuro / markerattrs=(symbol=circlefilled color=green); 
    reg x=Efficiency_WhKm y=PriceEuro / lineattrs=(color=brown);
    xaxis label="Efficiency (Wh/Km)";
    yaxis label="Price (Euro)";
    title "Efficiency vs. Price with Linear Regression Line";
run;

** Box plot for PowerTrain_num vs. PriceEuro;
proc sgplot data=electric;
    vbox PriceEuro / category=PowerTrain
        datalabel datalabelattrs=(size=8);
    xaxis label="PowerTrain";
    yaxis label="Price (Euro)";
    title "Box Plot of Price by PowerTrain";
run;

* Box plot for BodyStyle_num vs. PriceEuro;
proc sgplot data=electric;
    vbox PriceEuro / category=BodyStyle
        datalabel datalabelattrs=(size=8);
    xaxis label="BodyStyle";
    yaxis label="Price (Euro)";
    title "Box Plot of Price by BodyStyle";
run;


** Preprocessing the data;
** formatting the input variables;
proc format;
    value $ PowerTrain_fmt 'AWD' = 1 'RWD' = 2 'FWD' = 3;
        
    value $ BodyStyle_fmt 'Sedan'= 1 'Hatchback'= 2 'Liftback'= 3 'SUV'= 4 'MPV'= 5
        'Pickup' = 6 'Cabrio' = 7 'SPV'= 8 'Station' = 9;
run;

** Transforming PowerTrain and BodyStyle into numeric variables;
data electric;
	set electric;
	 format PowerTrain PowerTrain_fmt. BodyStyle BodyStyle_fmt.;
	 PowerTrain_n = put(PowerTrain, PowerTrain_fmt.);
	 BodyStyle_n = put(BodyStyle, BodyStyle_fmt.);
	 
     PowerTrain_num = input(PowerTrain_n, ?? best32.);
	 BodyStyle_num = input(BodyStyle_n, ?? best32.);
	 
	 drop BodyStyle_n PowerTrain_n;
run;

** View dataset structure ;
proc contents data=electric; 
run;


**descriptic statistics by each variable;
proc univariate data=electric;
    var PriceEuro TopSpeed_KmH Range_Km Efficiency_WhKm PowerTrain_num BodyStyle_num;
run;

** correlation of independent variables with dependent variable;
proc corr data=electric;
	var TopSpeed_KmH Range_Km Efficiency_WhKm PowerTrain_num BodyStyle_num;
	with PriceEuro;
run;

* Summary of the data;
proc summary data=electric print;
	var PriceEuro TopSpeed_KmH Range_Km Efficiency_WhKm PowerTrain_num BodyStyle_num;
run;


**Section 3;                    
* Modeling the data;
proc reg data=electric;
	model PriceEuro = TopSpeed_KmH Range_Km Efficiency_WhKm PowerTrain_num BodyStyle_num ;
run;

**Results1;
** Y = a + b*x1 + c*x2 + d*x3+...+n.xn; 
**PriceEuro = -61045 + 535.70692 * TopSpeed_KmH  + 26.25527 * Range_Km + 70.34048 * Efficiency_WhKm +
   -2918.60695 * PowerTrain_num + 1305.15916* BodyStyle_num;
** R-Sqare = 0.7096  and Adj R-Sq= 0.6946;
** Efficiency od model = 70.96% ;


*** Model Checking;
proc reg data=electric;
	model PriceEuro = TopSpeed_KmH Range_Km Efficiency_WhKm PowerTrain_num BodyStyle_num;
	plot student.*TopSpeed_KmH;
	plot student.*Range_Km;
	plot student.*Efficiency_WhKm;
	plot student.*PowerTrain_num;
	plot student.*BodyStyle_num;
	plot student.*p.;
	output out=residual 
		predicted=y_hat student=sresid;
run;
proc univariate data=residual normal;
	var sresid;
run;


** Transformation Y;
data electric;
	set electric;
	PriceEuro_log = log(PriceEuro);
run;

** Y = a + b*x1 + c*x2 + d*x3+...+n.xn;
**PriceEuro_log = -9.19842 + 0.00560 * TopSpeed_KmH  + 0.00072852 * Range_Km + 0.00284 * Efficiency_WhKm +
   -0.11294 * PowerTrain_num + 0.00921 * BodyStyle_num ;
** R-Sqare = 0.7867  and Adj R-Sq= 0.7757;
** Efficiency of model = 78.67%;

** After transformation of Y value;
proc reg data=electric;
	model PriceEuro_log = TopSpeed_KmH Range_Km Efficiency_WhKm PowerTrain_num BodyStyle_num;
run;


* Transformation X;
data electric;
	set electric;
	speed_log = log(TopSpeed_KmH) ;
	range_log = log(Range_Km)  ;
	efficiency_log = log(Efficiency_WhKm) ;
	power_log = log(PowerTrain_num);
	body_log = log(BodyStyle_num);
run;

** PriceEuro_log = 1.45740 + 1.18575 * TopSpeed_KmH  + 0.25662 * Range_Km + 0.34679 * Efficiency_WhKm +
   -0.19792 * PowerTrain_num + 0.03302 * BodyStyle_num;  
** R-Sqare = 0.7912 and Adj R-Sq= 0.7804 ;
** Efficiency of model = 79.12%;

** After transformation of both Y and X values;
proc reg data=electric;
	model PriceEuro_log = speed_log range_log efficiency_log power_log body_log;
	plot student. * p.;
run;

* Multicollinearity;
* VIF: Variance Inflation Factor, >5;
* Tolerance, <0.2;
* VIF = 1/Tolerance;
proc reg data=electric;
	model PriceEuro_log = speed_log range_log efficiency_log power_log body_log / vif tol collin spec;
run;


**section4;
**Finding Outliers and influencers;
proc reg data=electric;
	model PriceEuro_log = speed_log range_log efficiency_log power_log body_log / influence;
	output out=influence RSTUDENT=RStudent dffits=dffts  H=leverage COVRATIO=cov;
run;
** outliersdetection [RStudent > 2];
proc print data= influence;
var RStudent;
where RStudent > 2;
run;
** Obs	RStudent 17, 49, 73, 80, 85;

**Influencers detection [dffitsv > 2];
proc print data= influence;
var dffts;
where dffts > 2;
run;
**Obs	dffts 49;

**Hat Diag H;
**(2*6)/103= 0.116 ; 
proc print data= influence;
var leverage;
where leverage > 0.116;
run;
** Obs	leverage 49, 52, 73, 78, 83, 85, 92; 

** Cov Ratio: |Cov Ratio - 1| > 3*p/n;
** 3*6/103 = 0.174;
proc print data= influence;
var cov;
where (cov-1) > 0.174;
run;
** Obs	cov 52, 78, 83, 92;

**Overall;
**single: 17,80;
** Twice repetaed: 52, 73, 78, 85, 83, 92;
** Trice repeated: 49;


**section5;
** creating new dataset without the outliers and influencers ;
data new_electric;
    set electric;
    if _n_ in (17, 49,52, 73, 78, 80, 83, 85, 92) then delete;
run;


** building model for new dataset  ;
proc reg data=new_electric;
	model PriceEuro_log = speed_log range_log efficiency_log power_log body_log;
run;
**results;
**(PriceEuro_log = -2.16460	 + 1.45511 * TopSpeed_KmH  + 0.04703 * Range_Km + 0.99205 * Efficiency_WhKm
    -0.02814 * PowerTrain_num - -0.02786 * BodyStyle_num);
** R-Sqare = 0.8802 and Adj R-Sq= 0.8734;
** Efficiency of model = 88.02% ;


