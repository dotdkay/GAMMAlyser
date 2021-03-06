/*
Written by: Casper Madsen
Compiled and developed in: Dev-C++ 5.8.3 with C++11 flag

Ideas:
-Flag for use of eff calibration

-Flag for use of Ci or Bq

-Isotopes.txt


*/

#include <iostream>
#include <fstream>
#include <string>
#include <cstdlib> //used for atof function
#include <math.h>  //used for math functions like exp

using namespace std;


//run program with: GAMMAlyser filetoread TimeSinceEOS EOSBq Use_Currie Use_Eff
//GAMMAlyser c:\kemi\export.txt
//run program with: GAMMAlyser filetoread TimeSinceEOS EOSBq Use_Currie Use_Eff
//GAMMAlyser.exe c:\kemi\export.txt 99.81 36900000000 1 1 18F
//argument         [1]               [2]      [3]    [4][5] [6] 
class Isotope {
    string name;
    double halflife;
	double eff;
	double TimeSinceEOS;
	double EOSBq;
	bool useeff;
	
	double contamination;
	double activity;
	double realAct;
	double EOSAct;
	
  public:
  	Isotope ();
    void set_values (string,double,double,double,double,bool);
    void print_values();
    string get_name() {return name;}
    double get_pol() {return EOSAct;}
    double get_halflife() {return halflife;}
    double get_eff() {return eff;}
    double get_realAct() {return realAct;}
    double get_contamination() {return contamination;}
    void set_contamination (double);
    void calulate_values();
    //int area() {return width*height;}
};

Isotope::Isotope()
{
	contamination = 0;
}

void Isotope::calulate_values()
{
	realAct = contamination / eff;
	EOSAct = realAct * exp(TimeSinceEOS * (log(2)/halflife));	
}

void Isotope::set_contamination(double inconta) {
	//TODO: Check if Use_Currie = True, otherwise don't multiply by 37
	contamination = inconta*37;
}
void Isotope::set_values (string inname, double inhalflife, double inTimeSinceEOS, double inEOSBq, double ineff, bool inuseeff) {
  name = inname;
  halflife = inhalflife;
  TimeSinceEOS = inTimeSinceEOS;
  EOSBq = inEOSBq;
  eff = ineff;
  useeff = inuseeff;
}

void Isotope::print_values() {
	cout << "Name: " << name << endl;
	cout << "Halflife: " << halflife << endl;
	cout << "TimeSinceEOS: " << TimeSinceEOS << endl;
	cout << "EOSBq: " << EOSBq << endl;
	cout << "Eff: " << eff << endl;
	cout << "Useeff: " << useeff << endl;
	cout << "Contamination: " << contamination << endl;
	cout << "Real Activity: " << realAct << endl;
	cout << "Activity EOS: " << EOSAct << endl;
}




int main(int argc, char *argv[])
{
    using namespace std;

    //Below variables used for see if calculation should be done using
    //Curie when importing data and to correct with an efficiency correction
    string Use_Curie = argv[4];
    string Use_Eff = argv[5];

	/*
	if (Use_Curie == "1")
	{
		cout << "Use_Curie er " << Use_Curie << endl;
	
	}
	
	if (Use_Eff == "1")
	{
		cout << "Use_Eff er " << Use_Eff << endl;
	}
	*/	
	
	//To count how many isotopes we should look for, we loop through the isotopes.txt file to find number of lines.
	//which mean numberoflines = number of isotope objects to create
	string isofiletoread;
	ifstream numofisotopefile (argv[6]);
	
    //ifstream numofisotopefile ("isotopes.txt");
    //ifstream numofisotopefile (isofiletoread.c_str());
    int number_of_lines = 0;
 	std::string numelline;
 	while (std::getline(numofisotopefile, numelline))
        ++number_of_lines;

 	std::cout << "Number of lines in text file: " << number_of_lines << endl;
 	numofisotopefile.close();	
	
	Isotope isotopes[number_of_lines];
    

    //Below we loop through every line of the isotope file which are in the format
    //[isotope name to look for in the export file],[halftime in hours],[effiency correction]
    //i.e. CO-56,1854.2,2.4
    //For each isotope there'll be created an object of the type isotope with the
    //parameters from the isotope file.
    //Notice that the isotope file currently need to be placed in same folder as exe file
	string isotopeline;
	ifstream isotopefile (argv[6]);
	
	//ifstream isotopefile ("isotopes.txt");
	//ifstream isotopefile (isofiletoread.c_str());
    
    if (isotopefile.is_open())
    {
        string readisotope;
        double readhalftime;
        double readeff;
        int i = 0;
        while ( getline (isotopefile,isotopeline) )
        {
            int position = 0;
            //Find first comma and thereby Isotope name to search for in the export file
            position = isotopeline.find(",");
            readisotope = isotopeline.substr(0,position);

            //Find next comma, and copy from oldpos to newpos, that's the halftime to calculate with
            int oldpos = position;
            position = isotopeline.find(",",position+1);
            readhalftime = std::stod(isotopeline.substr(oldpos+1,position-oldpos-1));
            //diaf = std::stod(halftime);
            //Find next comma, and copy from oldpos to newpos, that's the effiency correction
            oldpos = position;
            position = isotopeline.find('\n',position+1);
            readeff = std::stod(isotopeline.substr(oldpos+1,position-oldpos-1));
            cout << "For the following line:" << endl;
            cout << isotopeline << '\n';
            cout << "We found the following values for:" << endl;
            cout << "Isotope:" << readisotope << endl;
            cout << "Halftime:" << readhalftime << endl;
            cout << "Effectivity" << readeff << endl;
			isotopes[i].set_values(readisotope,readhalftime,std::stod(argv[2]),std::stod(argv[3]),readeff,1);
			i++;

        }

    isotopefile.close();
    }

    else cout << "Unable to Isotope file" << endl;

/*
Below: Number of arguments and print them to screen
    cout << "Use_Curie" << Use_Curie << "; Use_Eff=" << Use_Eff << endl;



    cout << "There are " << argc << " arguments:" << endl;

    // Loop through each argument and print its number and value
    for (int nArg=0; nArg < argc; nArg++)
    {
        cout << nArg << " " << argv[nArg] << endl;
    }
*/


    string line; //used for reading in lines
    std::size_t found; //specify position of found string
    ifstream myfile (argv[1]); //open up the file specified as first commandline argument
    if (myfile.is_open())
    {
        while ( getline (myfile,line) ) //read a single line each time, untill end of file
        {
        	int j=0;
        	
			//For every line, loop through the objects in isotopes, and look for the name, if there's a match, set the values and calculate
        	while (j<number_of_lines)
        	{
        		//set isoname equal to the isotope we have reached in our loop
				string isoname = isotopes[j].get_name();
        		
        		//Print out the isotope we're looking for now
				//cout << "Isotope name to look for: " << isoname << endl;
        		
        		//Look for the fetched isotope name, and if it's not found we get that found=npos, otherwise we'll have found the string we're looking for
				found=line.find(isoname);
  				if (found!=std::string::npos) //if we have found the isotope name, then do this
  				{
					//Print out where we found the isotope name in the string
					//std::cout << "Isotope found at: " << found << '\n';
					
					
					string stringvalcontamination;
					double valcontamination;
					
					if (line.length() > 30) //this is to see if theres actually anything specified for that isotope, otherwise we'll set it to 0
					{
						//Copy part of the string where the contamination is located at, 30 char in, and copy 13 char from that
						stringvalcontamination = line.substr(29,13);
						//Convert string of contamination to a double
						valcontamination = std::stod(stringvalcontamination);
					}
					else
					{
						valcontamination = 0.0; //if no value is specified set isotope contamination to 0
					}
					
					
					//Set the value of the isotope to the contamination value
					isotopes[j].set_contamination(valcontamination);
					
					
				}
				j++; 
			}
        }
    myfile.close();
    }

    else cout << "Unable to open file";

//Below we no calculate the remaining values of the isotope contamination
	int i=0;
	while (i<number_of_lines)
	{
		
		isotopes[i].calulate_values();
		i++;
	}

//We now add all the contamination together
	double sum_of_pol = 0;
	
	i=0;
	while (i<number_of_lines)
	{
		sum_of_pol += isotopes[i].get_pol();
		i++;
	}
	
	cout << "Sum of polution: " << sum_of_pol << endl;
	double pol_at_EOS = sum_of_pol/std::stod(argv[3]);
	double pol_at_EXPIRE = sum_of_pol/(std::stod(argv[3])/pow(2.0,11)); //2 to the power of 11, because there's been 11 halftimes before expire
	
	cout << "Polution at EOS: " << pol_at_EOS << endl;
	cout << "Polution at Expire: " << pol_at_EXPIRE << endl;
	
	//Below we're writing all the values to the file: c:\kemi\cnuclide.txt
	
	
	//Below is running throug and printing the values of all the isotopes that's been read from the file: isotopes.txt 

	
	i=0;
	while (i<number_of_lines)
	{
		cout << "  " << endl;
		isotopes[i].print_values();
		i++;
		cout << "  " << endl;
	}

	ofstream resultfile ("c:/kemi/cnuclide.txt");
 	 if (resultfile.is_open())
  	 {
    	if (pol_at_EXPIRE < 0.001)
    	{
    		resultfile << "Produktion <font size=\"7\" color=\"green\">GODKENDT</font>" << endl;
		}
		else
		{
			resultfile << "Produktion <font size=\"7\" color=\"red\">IKKE GODKENDT</font>" << endl;
		}
    	resultfile << "Time since EOS [hours]: " << argv[2] << endl;
    	resultfile << "Bq at EOS: " << std::stod(argv[3]) << endl;
		resultfile << "Sum of polution: " << sum_of_pol << endl;
    	resultfile << "Polution at EOS: " << pol_at_EOS << endl;
	 	resultfile << "Polution at Expire: " << pol_at_EXPIRE << endl;
    	i=0;
		while (i<number_of_lines)
		{
			resultfile << "******************************************************** " << endl;
			resultfile << "For isotope: " << isotopes[i].get_name() << endl;
			resultfile << "******************************************************** " << endl;
			resultfile << "Used halflife: [hours] " << isotopes[i].get_halflife() << endl;
			resultfile << "Used efficiency: " << isotopes[i].get_eff() << endl;
			resultfile << "Contamination at measurement time: [Bq] " << isotopes[i].get_contamination() << endl;
			resultfile << "Effiency corrected contamination: [Bq] " << isotopes[i].get_realAct() << endl;
			resultfile << "Polution at EOS: [Bq] " << isotopes[i].get_pol() << endl;
			i++;
			resultfile << "  " << endl;
		}
    	resultfile.close();
  	 } 
  else cout << "Unable to open file";

 return 0;


}

