project_id="zeta-flare-449207-r0"
region="asia-south1-c"
af_region="asia-south1"
cidr="10.2.0.0/16"
file_path="/home/workstation/.ansible/secrets/service_account.json"
projects={
  project1={    
            name= "newProject-007"#lovercase uppercase - number
            project_id="new-project-test-0123-r007"
            # organization_id="test"
            billing_account = "" # enable cloud billing api 
            #cloud billing accounts add-iam-policy-binding billingaccountid  --member="serviceAccount:jenkins-server@project-id.iam.gserviceaccount.com" --role="roles/resourcemanager.projectCreator",--role="roles/billing.admin"
            # # cant create project unless organizational level permission
          },
}

compute_engine={
  gitlab-server={
      machine_type = "e2-standard-4",
      zone         = "asia-south1-c",
      image        =  "centos-stream-10"
      disk_size    = "50"
      disk_type    = "pd-ssd"
  },
  chef-server={
      machine_type = "e2-standard-4", # change standard 4gbram
      zone         = "asia-south1-c",
      image        =  "centos-stream-10"
      disk_size    = "20"
      disk_type    = "pd-ssd"
  },
  # jenkins-server={
  #     machine_type = "e2-standard-4",
  #     zone         = "asia-south1-c",
  #     image        =  "centos-stream-10"
  #     disk_size    = "20"
  #     disk_type    = "pd-ssd"
  # }
}