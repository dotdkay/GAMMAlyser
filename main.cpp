/*
Written by: Casper Madsen

Ideas:
-Flag for use of eff calibration

-Flag for use of Ci or Bq

-Isotopes.txt


*/
#include <iostream>
#include <fstream>
#include <string>
#include <cstdlib> //used for atof function

using namespace std;


//run program with: GAMMAlyser filetoread TimeSinceEOS EOSBq Use_Currie Use_Eff
//GAMMAlyser c:\kemi\export.txt


int main(int argc, char *argv[])
{
    using namespace std;

    //Below variables used for see if calculation should be done using
    //Curie when importing data and to correct with an efficiency correction
    bool Use_Curie = true;
    bool Use_Eff = true;


    string isotopeline;

    //Below we loop through every line of the isotope file which are in the format
    //[isotope name to look for in the export file],[halftime in hours],[effiency correction]
    //For each isotope there'll be created an object of the type isotope with the
    //parameters from the isotope file.
    //Notice that the isotope file currently need to be placed in c:/GAMMAlyser folder
    //properly change that so the file just needs to be where GAMMAlyser.exe is placed.
    ifstream isotopefile ("c:/GAMMAlyser/isotopes.txt");
    if (isotopefile.is_open())
    {
        string isotope;
        string halftime;
        double diaf;
        string eff;
        while ( getline (isotopefile,isotopeline) )
        {
            int position = 0;
            //Find first comma and thereby Isotope name to search for in the export file
            position = isotopeline.find(",");
            isotope = isotopeline.substr(0,position);

            //Find next comma, and copy from oldpos to newpos, that's the halftime to calculate with
            int oldpos = position;
            position = isotopeline.find(",",position+1);
            halftime = isotopeline.substr(oldpos+1,position-oldpos-1);
            diaf = std::stod(halftime);
            //Find next comma, and copy from oldpos to newpos, that's the effiency correction
            oldpos = position;
            position = isotopeline.find('\n',position+1);
            eff = isotopeline.substr(oldpos+1,position-oldpos-1);
            cout << "For the following line:" << endl;
            cout << isotopeline << '\n';
            cout << "We found the following values for:" << endl;
            cout << "Isotope:" << isotope << endl;
            cout << "Halftime:" << halftime << "ord lige efter!" << endl;
            cout << "Effectivity" << eff << endl;


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


    string line;
    ifstream myfile (argv[1]);
    if (myfile.is_open())
    {
        while ( getline (myfile,line) )
        {
        cout << line << '\n';
        }
    myfile.close();
    }

    else cout << "Unable to open file";

    return 0;
}
