module Handler.ProjectSignup where

import Import

import Model.ProjectSignup
import Model.License

projectSignupForm :: Html -> MForm Handler (FormResult ProjectSignup, Widget)
projectSignupForm _ = do
    licenses <- lift $ runDB getLicenses

    (projectNameRes, projectNameView) <- mreq textField (generateFieldSettings "Project Name" [("class", "form-control"), ("placeholder", "Project Name")]) Nothing
    (projectWebsiteRes, projectWebsiteView) <- mopt textField (generateFieldSettings "Website" [("class", "form-control"), ("placeholder", "Project Website")]) Nothing
    (projectTypeRes, projectTypeView) <- mreq (multiSelectFieldList getProjectTypes) (generateFieldSettings "Project Type" [("class", "form-control"), ("placeholder", "Project Type(s)")]) Nothing
    (projectTypeOtherRes, projectTypeOtherView) <- mopt textField (generateFieldSettings "ProjectTypeOther" [("class", "form-control"), ("placeholder", "Describe Other Project Type")]) Nothing
    (projectLicenseRes, projectLicenseView) <- mreq (multiSelectFieldList $ getLicenseLabels licenses) (generateFieldSettings "License" [("class", "form-control"), ("placeholder", "Select License(s)")]) Nothing
    (projectLocationRes, projectLocationView) <- mreq textField (generateFieldSettings "Location" [("class", "form-control"), ("placeholder", "Location Project is legally based out of")]) Nothing
    (projectLegalStatusRes, projectLegalStatusView) <- mreq (selectFieldList getLegalStatuses) (generateFieldSettings "Legal Status" [("class", "form-control"), ("placeholder", "Legal Status of Project")]) Nothing
    (projectLegalStatusCommentsRes, projectLegalStatusCommentsView) <- mopt textField (generateFieldSettings "Legal Status Comments" [("class", "form-control"), ("placeholder", "Additional Comments about Legal Status")]) Nothing
    (projectMissionRes, projectMissionView) <- mreq textareaField (generateFieldSettings "Mission" [("class", "form-control"), ("placeholder", "Describe your project's vision and mission")]) Nothing
    (projectGoalsRes, projectGoalsView) <- mreq textareaField (generateFieldSettings "Goals" [("class", "form-control"), ("placeholder", "Describe your project's short-term and long-term goals and deliverables")]) Nothing
    (projectFundsRes, projectFundsView) <- mreq textareaField (generateFieldSettings "Funds" [("class", "form-control"), ("placeholder", "Describe how your project will benefit from and make use of funds raised through Snowdrift.coop")]) Nothing

    let projectSignupRes = ProjectSignup 
                <$> projectNameRes 
                <*> projectWebsiteRes
                <*> projectTypeRes
                <*> projectTypeOtherRes
                <*> projectLicenseRes
                <*> projectLocationRes
                <*> projectLegalStatusRes
                <*> projectLegalStatusCommentsRes
                <*> projectMissionRes
                <*> projectGoalsRes 
                <*> projectFundsRes
    let widget = toWidget $(widgetFile "project_signup")
    return (projectSignupRes, widget)


getProjectSignupR :: Handler Html
getProjectSignupR = do
    ((form, widget), enctype) <- runFormGet projectSignupForm 
    defaultLayout $ do
        setTitle "Project Signup Form | Snowdrift.coop"
        [whamlet|
            <form method=POST enctype=#{enctype}>
                ^{widget}
                <input type=submit>
        |]

postProjectSignupR :: Handler Html
postProjectSignupR = do
    ((result, widget), enctype) <- runFormPost $ projectSignupForm 
    case result of
        FormSuccess project -> do
          projectcheck <- select $ from $ \a -> do
            where_ (a ^. ProjectSignupName ==. val (projectSignupName project) ||. ProjectName ==. val (projectSignupName project)
            return count (a ^. ProjectSignupName)
          if projectcheck > 0
            then defaultLayout $ do
                setTitle "Project Signup Form: Submission Error! | Snowdrift.coop"
                [whamlet|
                    <H1 Align=Center>Submission Error
                    <ul>
                        <li color=red>#{projectSignupName $ project} already exists on Snowdrift.  You may have already submitted a sign-up request, which is still under review.
                    <form method=GET action=@{ProjectSignupR} enctype=#{enctype}>
                        <button>Return to previous form
                |]
            else defaultLayout $ do
                runDB $ insert_ project 
                setTitle "Project Signup Form: Success! | Snowdrift.coop"
                [whamlet|
                    <H1 Align=Center>Success!
                    <br>
                    <p>Your application to add #{projectSignupName $ project} has been submitted for review by the Snowdrift administrators to validate that your project meets the standards for Snowdrift.  You will receive a response within 7 - 10 business days.
                    <p>If your application is approved, your project's default Snowdrift page will be created for you, at which point you can edit the content as you see fit.
                    <p>If your application is rejected, you will receive an e-mail explaining why your project does not meet Snowdrift's criteria.  
                    <H3 Align=Center>Thank you for your interest in Snowdrift!!
                |]
        FormFailure messages -> defaultLayout $ do
                setTitle "Project Signup Form: Submission Error! | Snowdrift.coop"
                [whamlet|
                    <H1 Align=Center>Submission Error
                    <ul>
                        $forall message <- messages
                            <li color=red>#{message}
                    <br>
                    <form .form-horizontal method=POST action=@{ProjectSignupR} enctype=#{enctype}>
                        ^{widget}
                        <input type=submit>
                |]
        FormMissing -> defaultLayout $ do
                setTitle "Project Signup Form | Snowdrift.coop"
                [whamlet|
                <form method=POST enctype=#{enctype}>
                    ^{widget}
                    <input type=submit>
                |]
