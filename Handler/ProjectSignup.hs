module Handler.ProjectSignup where

import Import

import Model.ProjectSignup
import Model.License




projectSignupForm :: Html -> MForm Handler (FormResult ProjectSignup, Widget)
projectSignupForm _ = do
    licenses <- lift $ runYDB getLicenses

    let projectTypeField = multiSelectFieldList getProjectTypes
        licenseField = multiSelectFieldList $ getLicenseLabels licenses
        legalStatusField = selectFieldList getLegalStatuses

    (projectNameRes, projectNameView)               <- mreq textField           (generateFieldSettings "Project Name" [("placeholder", "My Project")]) Nothing
    (projectWebsiteRes, projectWebsiteView)         <- mopt textField           (generateFieldSettings "Website" [("placeholder", "example.com")]) Nothing
    (projectTypeRes, projectTypeView)               <- mreq projectTypeField    (generateFieldSettings "Project Type" []) Nothing
    (projectTypeOtherRes, projectTypeOtherView)     <- mopt textField           (generateFieldSettings "ProjectTypeOther" []) Nothing
    (projectLicenseRes, projectLicenseView)         <- mreq licenseField        (generateFieldSettings "License" []) Nothing
    (projectLocationRes, projectLocationView)       <- mreq textField           (generateFieldSettings "Location" []) Nothing
    (projectLegalStatusRes, projectLegalStatusView) <- mreq legalStatusField    (generateFieldSettings "Legal Status" []) Nothing

    (projectLegalStatusCommentsRes, projectLegalStatusCommentsView)
                                                    <- mopt textField           (generateFieldSettings "Legal Status Comments" []) Nothing

    (projectMissionRes, projectMissionView)         <- mreq textareaField       (generateFieldSettings "Mission" [("placeholder", "Our mission is to...")]) Nothing
    (projectGoalsRes, projectGoalsView)             <- mreq textareaField       (generateFieldSettings "Goals" []) Nothing
    (projectFundsRes, projectFundsView)             <- mreq textareaField       (generateFieldSettings "Use of Funds" [("placeholder", "We will use funds raised to...")]) Nothing

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
    ((_, widget), enctype) <- runFormGet projectSignupForm 
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
          -- good thought, but probably better done with an insertUnique
          [ Value projectcheck :: Value Int64 ] <- runDB $ select $ from $ \(a, p) -> do
              where_ (a ^. ProjectSignupName ==. val (projectSignupName project) ||. p ^. ProjectName ==. val (projectSignupName project))
              return $ count (a ^. ProjectSignupName)

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
              else do
                  runDB $ insert_ project 
                  defaultLayout $ do
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
