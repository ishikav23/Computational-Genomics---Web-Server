#!/usr/bin/env python3

import streamlit as st
import subprocess
import os
import random

## installation
# conda create -n streamlit
# conda install pip
# pip install streamlit

## running:
# streamlit run ~/compgenomics/streamlit/myfile.py 

## to increase file upload limit:
# streamlit run ~/compgenomics/streamlit/myfile.py --server.maxUploadSize 1000


try:
    if jobIDs:
        pass
except:
    jobIDs = [['email', 'jobID'], ['licoricetree@gmail.com', '420']]



st.title("Computation Genomics 2023 Team 2 Webserver")
st.write("---")
st.header("Upload files")

# form to upload paired .fq files and submit to save files in 
# tmp directory

with st.form("submission_form"):
    st.write("Upload files and select job options")
#   slider_val = st.slider("Form slider")
    checkbox_val1 = st.checkbox("Option1")
    checkbox_val2 = st.checkbox("Option2")

    # file uploads
    file_upload = st.file_uploader('Choose files to upload', accept_multiple_files=True)        

    if len(file_upload) < 2:
        st.error('Please upload paired .fq/.fastq files')

    user_email = st.text_input(label="Enter email to recieve results", placeholder="youremail@email.com")
    if len(user_email) < 5:
        st.error("Enter a valid email")

    # Every form must have a submit button.
    submitted = st.form_submit_button("Submit")



if submitted:


    ## creating job IDs...? session ids go here
    #jobID = random.randint(100, 999)
    #jobIDs.append([user_email, jobID])

    #create jobID folder "job_"sessionID with output and input folders



    ## upload files to  directory.
    if len(file_upload) >= 2:
        try:
            for file in file_upload:
                file_details = {"FileName":file.name}
                with open(os.path.join("output",file.name),"wb") as f:
                    f.write(file.getbuffer())
            st.write("Files uploaded successfully")
        except:
            st.write("File upload failed, please try again")
    st.balloons()
    # st.write("You selected checkbox1, ", checkbox_val1, " and checkbox2, ", checkbox_val2)
    # st.write("You have submitted your files to be run with the selected options.")
    




    # send the email stuff
    st.write("Sending results to ", user_email, " \nJob ID: ", jobID)
    st.write(jobIDs)



    ## invoke another script hi.py and store output as a string
    #subprocess.run(["nextflow", "pipeline.nf"])
    script = subprocess.run(["python", "hi.py"], capture_output=True, text=True).stdout
    st.write(script)




