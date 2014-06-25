module View.User
    ( createUserForm
    , editUserForm
    , establishUserForm
    , previewUserForm
    , renderUser
    ) where

import Import

import           Widgets.ProjectPledges

import           Model.Markdown
import           Yesod.Markdown

import qualified Data.Map         as M
import qualified Data.Set         as S

import           Model.Role
import           Model.User
import           Widgets.Markdown (snowdriftMarkdownField)

createUserForm :: Maybe Text -> Form (Text, Text, Maybe Text, Maybe Text, Maybe Text)
createUserForm ident extra = do
    (identRes, identView) <- mreq textField "" ident
    (passwd1Res, passwd1View) <- mreq passwordField "" Nothing
    (passwd2Res, passwd2View) <- mreq passwordField "" Nothing
    (nameRes, nameView) <- mopt textField "" Nothing
    (avatarRes, avatarView) <- mopt textField "" Nothing
    (nickRes, nickView) <- mopt textField "" Nothing

    let view = [whamlet|
        ^{extra}
        <p>
            By registering, you agree to Snowdrift.coop's (amazingly ethical and ideal) #
                <a href="@{ToUR}">Terms of Use
                and <a href="@{PrivacyR}">Privacy Policy</a>.
        <table .table>
            <tr>
                <td>
                    E-mail or handle (private):
                <td>
                    ^{fvInput identView}
            <tr>
                <td>
                    Passphrase:
                <td>
                    ^{fvInput passwd1View}
            <tr>
                <td>
                    Repeat passphrase:
                <td>
                    ^{fvInput passwd2View}
            <tr>
                <td>
                    Name (public, optional):
                <td>
                    ^{fvInput nameView}
            <tr>
                <td>
                    Avatar (link, optional):
                <td>
                    ^{fvInput avatarView}
            <tr>
                <td>
                    IRC Nick (irc.freenode.net, optional):
                <td>
                    ^{fvInput nickView}
    |]

        passwdRes = case (passwd1Res, passwd2Res) of
            (FormSuccess a, FormSuccess b) -> if a == b then FormSuccess a else FormFailure ["passwords do not match"]
            (FormSuccess _, x) -> x
            (x, _) -> x

        result = (,,,,) <$> identRes <*> passwdRes <*> nameRes <*> avatarRes <*> nickRes

    return (result, view)

editUserForm :: User -> Form UserUpdate
editUserForm User{..} = renderBootstrap3 $
    UserUpdate
        <$> aopt' textField              "Public Name"                                    (Just userName)
        <*> aopt' textField              "Avatar image (link)"                            (Just userAvatar)
        <*> aopt' textField              "IRC nick @freenode.net)"                        (Just userIrcNick)
        <*> aopt' snowdriftMarkdownField "Blurb (used on listings of many people)"        (Just userBlurb)
        <*> aopt' snowdriftMarkdownField "Personal Statement (visible only on this page)" (Just userStatement)

-- | Form to mark a user as eligible for establishment. The user is fully established
-- when s/he accepts the honor pledge.
establishUserForm :: Form (Text, UTCTime)
establishUserForm = renderBootstrap3 $ (,)
    <$> (unTextarea <$> areq textareaField "Reason" Nothing)
    <*> lift (liftIO getCurrentTime)

previewUserForm :: User -> Form UserUpdate
previewUserForm user = renderBootstrap3 $
    UserUpdate
        <$> aopt hiddenField "" (Just $ userName user)
        <*> aopt hiddenField "" (Just $ userAvatar user)
        <*> aopt hiddenField "" (Just $ userIrcNick user)
        <*> hiddenMarkdown (userBlurb user)
        <*> hiddenMarkdown (userStatement user)

renderUser :: Maybe UserId -> UserId -> User -> Map (Entity Project) (Set Role) -> Widget
renderUser mviewer_id user_id user projects_and_roles = do
    let user_entity = Entity user_id user
        project_handle = error "bad link - no default project on user pages" -- TODO turn this into a caught exception

    $(widgetFile "user")

hiddenMarkdown :: Maybe Markdown -> AForm Handler (Maybe Markdown)
hiddenMarkdown Nothing               = fmap (fmap Markdown) $ aopt hiddenField "" Nothing
hiddenMarkdown (Just (Markdown str)) = fmap (fmap Markdown) $ aopt hiddenField "" (Just $ Just str)
