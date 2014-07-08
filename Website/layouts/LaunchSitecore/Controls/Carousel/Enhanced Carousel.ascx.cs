﻿using LaunchSitecore.Configuration.SiteUI.Base;
using Sitecore.Data;
using Sitecore.Data.Items;
using Sitecore.Links;
using Sitecore.Web.UI.WebControls;
using System;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;

namespace LaunchSitecore.layouts.LaunchSitecore.Controls.Carousel
{
  public partial class Enhanced_Carousel : SitecoreUserControlBase
  {
    private void Page_Load(object sender, EventArgs e)
    {
      rptItems.DataSource = DataSourceItems;
      rptItems.DataBind();
    }

    protected void rptItems_ItemDataBound(object sender, RepeaterItemEventArgs e)
    {
      if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
      {
        Item node = (Item)e.Item.DataItem;
        {
          FieldRenderer LinkText = (FieldRenderer)e.Item.FindControl("LinkText");
          FieldRenderer Title = (FieldRenderer)e.Item.FindControl("Title");
          FieldRenderer Caption = (FieldRenderer)e.Item.FindControl("Caption");
          FieldRenderer CarouselImage = (FieldRenderer)e.Item.FindControl("CarouselImage");
          HyperLink TextLink = (HyperLink)e.Item.FindControl("TextLink");
          EditFrame LinkFrame = (EditFrame)e.Item.FindControl("LinkFrame");
          HtmlControl carouselcaption = (HtmlControl)e.Item.FindControl("carouselcaption");

          if (LinkText != null && Caption != null && CarouselImage != null && TextLink != null && LinkFrame != null && Title != null && carouselcaption != null)
          {
            LinkText.Item = node;
            Title.Item = node;
            Caption.Item = node;
            CarouselImage.Item = node;

            LinkFrame.Buttons = "/sitecore/content/Applications/WebEdit/Edit Frame Buttons/Carousel Items";
            LinkFrame.DataSource = node.Paths.FullPath;

            if (node["Link Item"] != String.Empty)
            {
              Item targetItem = Sitecore.Context.Database.GetItem(new ID(node["Link Item"]));
              if (targetItem != null)
              {
                TextLink.NavigateUrl = LinkManager.GetItemUrl(targetItem);                
              }
            }

            if (node["Use Dark Text"] == "1") carouselcaption.Attributes.Add("class", "carousel-caption darktext");
          }
        }
      }
    }
  }
}