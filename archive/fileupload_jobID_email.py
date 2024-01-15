#!/usr/bin/env python3

import streamlit as st
import subprocess
import os
from random import randint, randrange
#from streamlit.report_thread import get_report_ctx
import threading
import smtplib
import time
import subprocess
from email.mime.multipart import MIMEMultipart
from email.mime.application import MIMEApplication
from email.mime.text import MIMEText
from pathlib import Path

## installation
# pip install streamlit

## run with increase file upload limit:
# streamlit run ~/compgenomics/streamlit/myfile.py --server.maxUploadSize 1000

#try:
#    if jobIDs:
#        pass
#except:
#    jobIDs = [['email', 'jobID'], ['licoricetree@gmail.com', '420']]

#Function to create a session id
#def _get_session():
#    import streamlit.report_thread as ReportThread
#    from streamlit.server.server import Server
#    session_id = get_report_ctx().session_id
#    session_info = Server.get_current()._get_session_info(session_id)
#    if session_info is None:
#        raise RuntimeError("Couldn't get your Streamlit Session object.")
#    return session_info.session




def send_email(user_email,session_id,path):
    email_address = "comgenomics2023team2@outlook.com"
    password = "comgenomicsTeam2@"

    # create a message
    message = MIMEMultipart()
    message['From'] = email_address
    message['To'] = user_email
    message['Subject'] = "Job Completed"
    message.attach(MIMEText(f"Your background job is complete! Your job ID is {session_id}. Please use this ID to retrieve the result."))

    with open(f'{path}/output/line_number.txt') as fh:
        attachment = MIMEApplication(fh.read(),_subtype='txt')
        attachment.add_header('Content-Disposition','attachment',filename="line_number.txt")
        message.attach(attachment)

    # Create SMTP session for sending the mail
    smtp_session = smtplib.SMTP('smtp.office365.com', 587)
    smtp_session.starttls()
    smtp_session.login(email_address, password)
    smtp_session.sendmail(email_address, user_email, message.as_string())
    smtp_session.quit()


def run_job(path):
    #TODO
    # perform tasks here
    #Brendon's nextflow command goes here...
    #Brandon's script should take in the path or the session id.
    cmd = f"nextflow run /home/projects/team2/app/scripts/cgen_flow.nf --job {session_id}"
    #cmd = f'for FILE in {path}/input/*fq.gz; do wc -l $FILE; done > {path}/output/line_number.txt'
    subprocess.run(cmd, shell=True)
    # time.sleep(10) # example wait time

#Try 2 for session id

def _get_session():
    id = ''.join(["{}".format(randint(0, 9)) for num in range(0, 12)])
    return id

st.title("Computation Genomics 2023 Team 2 Webserver")
st.write("---")
st.header("Upload files")

# form to upload paired .fq files and submit to save files in 
# tmp directory

with st.form("submission_form"):
    st.write("Upload files and select job options")
    #checkbox_val1 = st.checkbox("Option1")
    #checkbox_val2 = st.checkbox("Option2")

    # file uploads
    file_upload = st.file_uploader('Choose files to upload', accept_multiple_files=True)        

    if len(file_upload) < 2:
        st.error('Please upload paired .fq/.fastq files')

    user_email = st.text_input(label="Enter email to recieve results", placeholder="cgulvik6@gatech.edu")

    if len(user_email) < 5:
        st.error("Enter a valid email")

    # Every form must have a submit button.
    submitted = st.form_submit_button("Submit")



if submitted:
    upload_success = False #initialize a parameter to check if succesfully uploaded and saved
    session_id = None #initalize the session id to null


    #create jobID folder sessionID with output and input folders
    ## upload files to  directory.
    if len(file_upload) >= 2:
        try:
                
            track_file = open("job_tracking.txt", "a")
            session_id = _get_session()
            track_file.write(session_id+"\t"+user_email+"\n")
            track_file.close()
            Path('jobs').mkdir(exist_ok=True)
            os.system(f"mkdir jobs/{session_id}")
            os.system(f"mkdir jobs/{session_id}/input")
            os.system(f"mkdir jobs/{session_id}/output")

            for file in file_upload:
                file_details = {"FileName":file.name}
                #with open(os.path.join(f"{session_id}/input",file.name),"wb") as f:
                with open(f"jobs/{session_id}/input/{file.name}", "wb") as f:
                    f.write(file.getbuffer())

            #success     
            upload_success = True
            st.write("Files uploaded successfully")   
            st.balloons()

        except:
            st.write("File upload failed, please try again")


    #run the job and send the email stuff only when user hit submit button 
    if upload_success:  # only when successfully uploaded
        job_thread = threading.Thread(target=run_job(f"jobs/{session_id}"))
        job_thread.start()

        # Display message to user
        st.write("Your background job is running.")

        # Wait until job is finished
        while job_thread.is_alive():
            time.sleep(1)

        # Send email notification when job is complete
        send_email(user_email,session_id,path=f"jobs/{session_id}")
        st.write("Your background job is complete. An email has been sent to notify you.")






